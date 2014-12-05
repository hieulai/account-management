module ApplicationHelper
  def root_user
    (current_user && current_user.employers.any?) ? current_user.employers.first : current_user
  end

  def phone_for(user)
    if user.profile.phone_1.present?
      "#{number_to_phone(user.profile.phone_1, :area_code => true)} #{user.profile.phone_tag_1}"
    elsif user.profile.phone_2.present?
      "#{number_to_phone(user.profile.phone_2, :area_code => true)} #{user.profile.phone_tag_2}"
    end
  end

  def website_for(user)
    if user.profile.website
      link_to user.profile.website, "http://#{user.profile.website}"
    end
  end
end
