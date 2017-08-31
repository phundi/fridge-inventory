module ApplicationHelper
  def has_permit(name)
    permissions = User.find_by_sql("SELECT p.name AS n FROM user u
        INNER JOIN user_role r ON u.user_id = r.user_id
        INNER JOIN permission_role pr ON pr.role_id = r.role_id
        INNER JOIN permission p ON p.permission_id = pr.permission_id
      WHERE u.user_id = #{session[:user_id]}").map(&:n)

    permissions.include?(name)
  end
end


