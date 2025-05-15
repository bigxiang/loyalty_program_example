module Api
  module V1
    module Points
      class Earn
        include ActiveModel::Validations

        attr_accessor :user_identifier, :birthday, :transaction_identifier, :is_foreign, :amount_in_cents

        validates :user_identifier, presence: true
        validates :birthday, presence: true
        validates :transaction_identifier, presence: true
        validates :is_foreign, inclusion: { in: [ true, false ] }
        validates :amount_in_cents, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 0 }

        def initialize(user_identifier:, birthday:, transaction_identifier:, is_foreign:, amount_in_cents:)
          @user_identifier = user_identifier
          @birthday = birthday
          @transaction_identifier = transaction_identifier
          @is_foreign = is_foreign
          @amount_in_cents = amount_in_cents
        end

        def call
          return Result.new(success: false, errors: errors.full_messages) if invalid?

          ActiveRecord::Base.transaction do
            end_user = find_or_create_user
            end_user_transaction = create_transaction(end_user)

            Result.new(
              success: true,
              data: {
                transaction_identifier: end_user_transaction.transaction_identifier,
                user_identifier: end_user.identifier,
                points_earned: end_user_transaction.points_earned,
                current_points: end_user.current_points,
                monthly_points: end_user.monthly_points
              }
            )
          end
        rescue ActiveRecord::RecordInvalid => e
          if e.message =~ /Transaction identifier has already been taken/
            Result.new(success: false, errors: [ "This transaction has already been processed" ])
          else
            raise e
          end
        rescue ActiveRecord::RecordNotUnique
          Result.new(success: false, errors: [ "This transaction has already been processed" ])
        end

        private

        def find_or_create_user
          user = EndUser.find_by(identifier: user_identifier)
          return user if user

          EndUsers::Create.call(identifier: user_identifier, birthday:, registered_at: Time.zone.now)
        end

        def create_transaction(end_user)
          EndUserTransactions::Create.call(
            end_user:,
            transaction_identifier:,
            is_foreign:,
            amount_in_cents:
          )
        end
      end
    end
  end
end
