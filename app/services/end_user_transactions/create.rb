module EndUserTransactions
  class Create
    def self.call(end_user:, transaction_identifier:, is_foreign:, amount_in_cents:)
      new(end_user:, transaction_identifier:, is_foreign:, amount_in_cents:).call
    end

    def initialize(end_user:, transaction_identifier:, is_foreign:, amount_in_cents:)
      @end_user = end_user
      @transaction_identifier = transaction_identifier
      @is_foreign = is_foreign
      @amount_in_cents = amount_in_cents
    end

    def call
      ActiveRecord::Base.transaction do
        transaction = end_user.transactions.create!(transaction_identifier:, is_foreign:, amount_in_cents:, points_earned: 0)

        point = PointRules::Apply.call(transaction:)
        points_earned = point.points

        transaction.update!(points_earned:)

        account = end_user.account
        account.update!(
          current_points: account.current_points + points_earned,
          total_spent_in_cents: account.total_spent_in_cents + amount_in_cents
        )

        transaction
      end
    end

    private

    attr_reader :end_user, :transaction_identifier, :is_foreign, :amount_in_cents
  end
end
