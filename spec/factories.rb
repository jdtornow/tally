FactoryBot.define do
  factory :photo do
    sequence(:url) { |n| "https://example.com/photos/blah-#{ n }" }
  end

  factory :record, class: "Tally::Record" do
    day { Date.today }
    value { 100 }
    sequence(:key) { |n| "clicks.#{ n }" }
  end
end
