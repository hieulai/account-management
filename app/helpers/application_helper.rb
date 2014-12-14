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

  def sorted_th(field = [])
    tag = ""
    class_name = 'sorting'
    sort_dir = "asc"
    if params[:sort_field] == field[1]
      if params[:sort_dir] == "asc"
        class_name = "sorting_asc"
        sort_dir = "desc"
      else
        class_name = "sorting_desc"
      end
    end
    class_name+= " #{field[2]}" if field[2]
    tag += content_tag :th, :class => class_name do
      link_to(field[0], params.merge(sort_field: field[1], sort_dir: sort_dir))
    end
    raw(tag)
  end
end
