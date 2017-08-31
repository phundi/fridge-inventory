class UserController < ApplicationController
  def index
    @users = User.all.order(:username)
  end

  def new
    if request.post?

      password = BCrypt::Password.create(params[:pass])
      user = User.new(
          username: params[:username],
          first_name: params[:first_name],
          last_name: params[:last_name],
          password: password,
          gender: params[:gender],
          designation: params[:designation],
          email: params[:email]
      )

      user.middle_name = params[:other_name] if !params[:other_name].blank?

      if !params[:image].blank?
        uploaded_io = params[:image]
        File.open(Rails.root.join('public', 'uploads', params[:username]), 'wb') do |file|
          file.write(uploaded_io.read)
        end

        user.image = "/uploads/#{params[:username]}"
      end

      user.save

      redirect_to '/user/index'
    end

    @user = User.new
    @action = '/user/new'
  end

  def view
    @user = User.find(params[:user_id])
  end

  def delete
    u = User.find(params[:user_id])
    if u.deleted_at.present?
      u.update_attributes(:deleted_at => nil)
    else
      u.update_attributes(:deleted_at => Time.now)
    end
    redirect_to '/user/index'
  end

  def edit
    @user = User.find(params[:user_id])

    if request.post?

      password = BCrypt::Password.create(params[:pass])

      @user.username = params[:username] if params[:username].present?
      @user.first_name = params[:first_name]
      @user.last_name = params[:last_name]
      @user.password = password if params[:pass].present?
      @user.gender = params[:gender]
      @user.designation = params[:designation] if params[:designation].present?
      @user.email = params[:email] if params[:email].present?
      @user.middle_name = params[:other_name] if params[:other_name].present?

      if !params[:image].blank?
        uploaded_io = params[:image]
        File.open(Rails.root.join('public', 'uploads', @user.username), 'wb') do |file|
          file.write(uploaded_io.read)
        end

        @user.image = "/uploads/#{@user.username}"
      end

      @user.save

      flash[:notice] = "Successfully updated user:  #{@user.username}"
      redirect_to '/user/index'
    end

    @action = '/user/edit'
  end

  def change_password
    @user = User.find(params[:user_id])

    if request.post? && @user.password_matches?(params[:old_pass])
      @user.password = BCrypt::Password.create(params[:pass])

      if !params[:image].blank?
        uploaded_io = params[:image]
        File.open(Rails.root.join('public', 'uploads', @user.username), 'wb') do |file|
          file.write(uploaded_io.read)
        end

        @user.image = "/uploads/#{@user.username}"
      end

      @user.save

      redirect_to "/"
    end

    @action = '/user/change_password'
  end

  def logout
    redirect_to '/login'
  end

  def login
    reset_session

    if request.post? and params[:email].present? && params[:password].present?
      user = User.where(:username => params[:email]).first
      if user.blank?
        user = User.where(:email => params[:email]).first
      end

      if user.present? && user.password_matches?(params[:password]) && user.deleted_at.blank?
        session[:user_id] = user.id
        redirect_to '/' and return
      end
    end

    render :layout => false
  end

  def roles
    @roles = Role.all.order('name')
  end

  def new_role
    @role = Role.new
    @action = "/user/new_role"
    if request.post?
      Role.create(name: params[:name], description: params[:description])
      redirect_to "/user/roles" and return
    end
  end

  def edit_role
    @action = "/user/edit_role"
    @role = Role.find(params[:role_id])
    if request.post?
      @role.name = params[:name]
      @role.description = params[:description]
      @role.save
      redirect_to "/user/roles" and return
    end
  end

  def delete_role
    permission_roles = PermissionRole.find_by_sql("SELECT * FROM permission_role WHERE role_id = #{params[:role_id]}")
    if permission_roles.blank?
    role = Role.find(params[:role_id])
    role.destroy
    flash[:error] = "Successfully deleted role"
    else
      flash[:error] = "Role already in use by #{permission_roles.count} items"
    end

    redirect_to '/user/roles'
  end

  def view_role
    @role = Role.find(params[:role_id])
  end

  def permissions
    @permissions = Permission.all.order('name')
  end

  def new_permission
    @permission = Permission.new
    @action = "/user/new_permission"
    if request.post?
      Permission.create(name: params[:name], display_name: params[:display_name])
      redirect_to "/user/permissions" and return
    end
  end

  def edit_permission
    @action = "/user/edit_permission"
    @permission = Permission.find(params[:permission_id])
    if request.post?
      @permission.name = params[:name]
      @permission.display_name = params[:display_name]
      @permission.save
      redirect_to "/user/permissions" and return
    end
  end

  def delete_permission
    permission_permissions = PermissionRole.find_by_sql("SELECT * FROM permission_role WHERE permission_id = #{params[:permission_id]}")
    if permission_permissions.blank?
      permission = Permission.find(params[:permission_id])
      permission.destroy
      flash[:error] = "Successfully deleted permission"
    else
      flash[:error] = "Permission already in use by #{permission_permissions.count} items"
    end

    redirect_to '/user/permissions'
  end

  def view_permission
    @permission = Permission.find(params[:permission_id])
  end

  def role_permissions
    @role_ids = Role.all.map(&:role_id)
    @role_names = Role.all.map(&:name)

    @perm_ids = Permission.all.map(&:permission_id)
    @perm_names = Permission.all.map(&:name)

    if request.post?
      perm_roles = params[:permission_roles]
      PermissionRole.destroy_all
      perm_roles.each do |perm_id, data|
        data.each do |role_id, selected|
          if selected == '1'
            PermissionRole.create(permission_id: perm_id, role_id: role_id)
          end
        end
      end

      redirect_to '/'
    else
      @permissions = {}
      @perm_ids.each do |perm|
        @permissions[perm] = {}
        @role_ids.each do |role|
          q = PermissionRole.where(permission_id: perm, role_id: role)
          if q.length > 0
            @permissions[perm][role] = true
          else
            @permissions[perm][role] = false
          end
        end
      end
    end
  end

  def user_roles 
    @role_ids = Role.all.map(&:role_id)
    @role_names = Role.all.map(&:name)

    @user_ids = User.all.map(&:user_id)
    @user_names = User.all.map(&:name)

    if request.post?
      user_roles = params[:user_roles]
      UserRole.destroy_all
      user_roles.each do |user_id, data|
        data.each do |role_id, selected|
          if selected == '1'
            UserRole.create(user_id: user_id, role_id: role_id)
          end
        end
      end

      redirect_to '/'
    else
      @users = {}
      @user_ids.each do |user|
        @users[user] = {}
        @role_ids.each do |role|
          q = UserRole.where(user_id: user, role_id: role)
          if q.length > 0
            @users[user][role] = true
          else
            @users[user][role] = false
          end
        end
      end

      raise @users.inspect
    end
  end
end
