module Accounting
  class JournalEntry < ApplicationRecord
    has_many :postings
    has_many :accounts, through: :postings

    validates_presence_of :description, :reference_type, :reference_id
  end
end
