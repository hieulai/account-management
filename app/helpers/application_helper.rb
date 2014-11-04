module ApplicationHelper
  def root_user
    (current_user && current_user.owners.any?) ? current_user.owners.first : current_user
  end
end
