class PhotosController < ApplicationController
  before_action :authenticate_user!, only: %i(create)

  def create
    if params[:photo].present?
      @photo = Photo.new(photo_params)
      @photo_uri = set_uri(@photo.photo.blob.key)
      @photo.user_id = current_user.id
      @labels = AnriGoogleCloudVision.new(@photo_uri).response
      @label = @photo.labels.build(@labels)
      @label.save
      @set_labels = set_labels(@labels, @photo)
      if @photo.save
        render 'components/posts/tweets_index', local: { photo_uri: @photo_uri, label: @set_labels }
      else
        render 'components/posts/photos_index'
      end
    else
      render 'components/posts/photos_index'
    end
  end

  private

  def photo_params
    params.require(:photo).permit(:photo)
  end

  def set_labels(label, photo)
    @labels = ""
    @photo.labels.each do |label|
    @labels << "#" + label.label1 + " " +
               "#" + label.label2 + " " +
               "#" + label.label3 + " " +
               "#" + label.label4 + " " +
               "#" + label.label5
    end
    @labels
  end
end
