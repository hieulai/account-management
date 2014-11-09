FactoryGirl.define do

  sequence :string do |n|
    "Lorem #{n}"
  end

  sequence :number do |n|
    "#{n}"
  end

  sequence :website do |n|
    "http://acme-#{n}.com"
  end

  sequence :date do |n|
    Date.new(2000, 12, 31) + n.days
  end

  sequence :email do |n|
    "object#{n}@example.com"
  end
end