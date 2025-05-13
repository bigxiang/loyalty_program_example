module EndUsers
  class Create
    def self.call(identifier:, birthday:, registered_at:)
      new(identifier:, birthday:, registered_at:).call
    end

    def initialize(identifier:, birthday:, registered_at:)
      @identifier = identifier
      @birthday = birthday
      @registered_at = registered_at
    end

    def call
      ActiveRecord::Base.transaction do
        end_user = EndUser.create!(identifier:, birthday:, registered_at:)
        end_user.create_account!(level: EndUser::MIN_LEVEL, current_points: 0, monthly_points: 0, total_spent_in_cents: 0)
        end_user
      end
    end

    private

    attr_reader :identifier, :birthday, :registered_at
  end
end
