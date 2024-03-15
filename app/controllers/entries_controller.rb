class EntriesController < ApplicationController
  before_action :set_entry, only: %i[ show ]

  def show
  end

  private

    def set_entry
      @entry = Entry.find(params[:id])
    end
end
