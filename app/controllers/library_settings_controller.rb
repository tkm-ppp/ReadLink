class LibrarySettingsController < ApplicationController
    def settings
      @search_term = params[:search]
      @libraries = Library.search(@search_term) if @search_term.present?
      @user_libraries = current_user.libraries
    end

    def create
      if params[:library_ids].present?
        libraries = Library.where(id: params[:library_ids])
        libraries.each do |library|
          current_user.libraries << library unless current_user.libraries.include?(library)
        end
        flash[:notice] = "図書館が追加されました。"
      end
      redirect_to library_settings_path(search: params[:search])
    end

    def destroy
      library = Library.find(params[:library_id])
      current_user.libraries.delete(library)
      redirect_to library_settings_path(search: params[:search])
    end
end
