class Public::EntriesController < PublicController
  before_action :set_entry, only: %i[ show ]
  before_action :authorize

  def show
  end

  private

    def authorize
      return unless @entry.draft?

      if @entry.blog.user != current_user
        raise ActiveRecord::RecordNotFound
      end
    end

    def set_entry
      @entry = Entry.find(params[:id])
    end
end
