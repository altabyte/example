class MoveAndRemoveUserRoles < ActiveRecord::Migration
  def change
    User.reset_column_information

    execute 'UPDATE users set role_id = (select max(role_id) from roles_users where user_id = users.id)'

    drop_table :roles_users
  end
end
