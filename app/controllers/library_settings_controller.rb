class LibrarySettingsController < ApplicationController
  require 'geocoder'

  def index
    fetch_libraries # 検索結果を取得
    @user_libraries = current_user.libraries.group_by(&:city)
    @near_libraries = params[:near_libraries]
  end

  def create
    if params[:library_ids].present?
      library_ids = params[:library_ids]
      library_ids.each do |library_id|
        library = Library.find(library_id)
        current_user.libraries << library unless current_user.libraries.include?(library)
      end
      current_user.save
      flash[:notice] = "図書館が追加されました。"
    end
    redirect_to library_settings_path(search: params[:search])
  end

  # 追加: 現在の市町村の図書館を保存するためのアクション
  def save_current_city_libraries
    city = params[:city]

    if city.blank?
      render json: { error: "City not provided" }, status: :bad_request
      return
    end

    libraries = Library.where(city: city)

    if libraries.empty?
      render json: { error: "図書館がまちにありません: #{city}" }, status: :not_found
      return
    end

    libraries.each do |library|
      current_user.libraries << library unless current_user.libraries.include?(library)
    end

    current_user.save

    render json: { message: "あなたの街の図書館をお気に入りに設定しました" }, status: :ok
  end

  def destroy
    library = Library.find(params[:library_id])
    current_user.libraries.delete(library)
    flash[:notice] = "図書館が削除されました。"
    redirect_to library_settings_path(search: params[:search])
  end

   def nearby
    latitude = params[:latitude].to_f
    longitude = params[:longitude].to_f

    if latitude.zero? || longitude.zero?
      flash[:alert] = "位置情報が取得できませんでした。"
      redirect_to library_settings_path
      return
    end

    # Geocoder を使用して市町村を取得
    results = Geocoder.search([latitude, longitude])
    if results.present?
      city = results.first.city
    else
      flash[:alert] = "現在地から市町村を特定できませんでした。"
      redirect_to library_settings_path
      return
    end

    # 現在の市町村にある全ての図書館を取得
    @near_libraries = Library.where(city: city).group_by(&:city)

    @user_libraries = current_user.libraries.group_by(&:city) if user_signed_in?

    # 近くの図書館をJSON形式で返す
    render json: { libraries: @near_libraries, city: city }
  end


  def distance(lat1, lon1, lat2, lon2)
    rad_per_deg = Math::PI/180
    rkm = 6371
    dlon_rad = (lon2-lon1) * rad_per_deg
    dlat_rad = (lat2-lat1) * rad_per_deg
    lat1_rad, lon1_rad = lat1*rad_per_deg, lon1*lon1_rad
    lat2_rad, lon2_rad = lat2*rad_per_deg, lon2*lon1_rad

    a = Math.sin(dlat_rad/2)**2 + Math.cos(lat1_rad) * Math.cos(lat2_rad) * Math.sin(dlon_rad/2)**2
    c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1-a))

    rkm * c
  end
end