module Api
  module V1
    module Rewards
      class Issue
        include ActiveModel::Validations

        attr_accessor :user_identifier

        validates :user_identifier, presence: true

        def initialize(user_identifier:)
          @user_identifier = user_identifier
        end

        def call
          return Result.new(success: false, errors: errors.full_messages) if invalid?

          @user = EndUser.find_by(identifier: user_identifier)
          return Result.new(success: false, errors: [ "User not found" ]) if @user.nil?

          @reward = RewardRules::Apply.call(user:)
          return Result.new(success: true, data: { message: "No rewards applicable" }) if @reward.items.empty?

          track_issuance
          reward_items = sum_up_reward_items
          Result.new(success: true, data: { message: "Rewards issued", reward_items: })
        # This is unlikely to happen because we will read the data when verifying if the rule can be applied,
        # but we're adding this rescue to be safe.
        rescue ActiveRecord::RecordInvalid => e
          if e.message =~ /Issurance identifier has already been taken/
            Result.new(success: false, errors: [ "This reward has already been issued to this user" ])
          else
            raise e
          end
        # This is still required because we make sure no duplicate rewards are issued in the DB level.
        rescue ActiveRecord::RecordNotUnique
          Result.new(success: false, errors: [ "This reward has already been issued to this user" ])
        end

        private

        attr_reader :user, :reward

        def sum_up_reward_items
          reward.items.group_by(&:name).map do |name, items|
            {
              name: name,
              quantity: items.sum(&:quantity)
            }
          end
        end

        def track_issuance
          ActiveRecord::Base.transaction do
            # Create all rewards in a single transaction
            reward.items.each do |item|
              # Generate a consistent transaction ID based on user and reward rule
              transaction_identifier = generate_transaction_id(user, item.rule_id)

              EndUserReward.create!(
                user: user,
                reward_rule_id: item.rule_id,
                transaction_identifier:,
                issued_at: Time.current
              )
            end
          end
        end

        def generate_transaction_id(user, rule_id)
          # Create a consistent transaction ID based on user and reward rule
          # This ensures the same user can't get the same reward twice in concurrent requests
          Digest::MD5.hexdigest("#{user.id}:#{rule_id}:#{Time.current.beginning_of_day.to_i}")
        end
      end
    end
  end
end
