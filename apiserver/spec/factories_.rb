FactoryGirl.define do
  # This will use the User class (Admin would have been guessed)
  factory :admin, class: User do
    username "username"
    email 'mail@example.com'
    # password
  end
end
