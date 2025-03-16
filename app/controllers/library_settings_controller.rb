class LibrarySettingsController < ApplicationController
    def settings
      @search_term = params[:search]
      @libraries = @search_term.present? ? Library.search(@search_term) : []
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

    def nearby
      latitude = params[:lat]
      longitude = params[:lng]
  
      if latitude.present? && longitude.present?
        @libraries = Library.all.sort_by { |library| distance(latitude.to_f, longitude.to_f, library.latitude.to_f, library.longitude.to_f) }
  
        @libraries_by_city = @libraries.group_by(&:city)
      else
        @libraries_by_city = {}
        flash[:alert] = "現在地が取得できませんでした。"
      end
  
      render 'library_settings/settings'
    end
  
    private
  
    def distance(lat1, lon1, lat2, lon2)
      rad_per_deg = Math::PI/180
      rkm = 6371
      dlon_rad = (lon2-lon1) * rad_per_deg
      dlat_rad = (lat2-lat1) * rad_per_deg
      lat1_rad, lon1_rad = lat1*rad_per_deg, lon1*rad_per_deg
      lat2_rad, lon2_rad = lat2*rad_per_deg, lon2*lon1_rad
  
      a = Math.sin(dlat_rad/2)**2 + Math.cos(lat1_rad) * Math.cos(lat2_rad) * Math.sin(dlon_rad/2)**2
      c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1-a))
  
      rkm * c
    end
  end