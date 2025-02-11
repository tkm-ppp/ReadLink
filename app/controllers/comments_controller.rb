# app/controllers/comments_controller.rb
class CommentsController < ApplicationController
  def create
    Rails.logger.debug "Comment params: #{comment_params.inspect}" # リクエストパラメータをログ出力

    @comment = Comment.new(comment_params)
    if @comment.save
      # コメント投稿成功時の処理 (例: リダイレクト、JavaScriptでの画面更新など)
      redirect_to library_detail_path(libid: @comment.library_detail_id), notice: 'コメントが投稿されました。' # 例: リダイレクト
    else
      # コメント投稿失敗時の処理 (例: エラーメッセージ表示)
      redirect_to library_detail_path(libid: @comment.library_detail_id), alert: 'コメントの投稿に失敗しました。' # 例: リダイレクト
    end
  end

  def index
    @library_detail_id = params[:library_detail_id]
    @comments = Comment.where(library_detail_id: @library_detail_id)
    respond_to do |format|
    format.html { render partial: 'comments/index', locals: { comments: @comments } }
    format.json { render json: @comments }
    end
  end

  def destroy
    @comment = Comment.find(params[:id])
    @comment.destroy
    redirect_to library_path(@library), notice: 'コメントが削除されました'
  end

  private


  def comment_params
    params.require(:comment).permit(:body, :library_detail_id)
  end
end
