class TagsController < ApplicationController
  before_action :set_tag, only: %i[ show edit update destroy ]

  # GET /tags or /tags.json
  def index
    @tags = Current.user.tags.includes(:bookmarks)
  end

  # GET /tags/search
  def search
    query = params[:q].to_s.strip.downcase
    @tags = Current.user.tags.where("LOWER(name) LIKE ?", "%#{query}%").limit(10)

    respond_to do |format|
      format.json { render json: @tags.select(:id, :name) }
    end
  end

  # GET /tags/1 or /tags/1.json
  def show
    @bookmarks = @tag.bookmarks
  end

  # GET /tags/new
  def new
    @tag = Tag.new
  end

  # GET /tags/1/edit
  def edit
  end

  # POST /tags or /tags.json
  def create
    @tag = Tag.new(tag_params)
    @tag.user = Current.user

    respond_to do |format|
      if @tag.save
        format.html { redirect_to @tag, notice: "Tag was successfully created." }
        format.json { render :show, status: :created, location: @tag }
      else
        format.html { render :new, status: :unprocessable_content }
        format.json { render json: @tag.errors, status: :unprocessable_content }
      end
    end
  end

  # PATCH/PUT /tags/1 or /tags/1.json
  def update
    respond_to do |format|
      if @tag.update(tag_params)
        format.html { redirect_to @tag, notice: "Tag was successfully updated." }
        format.json { render :show, status: :ok, location: @tag }
      else
        format.html { render :edit, status: :unprocessable_content }
        format.json { render json: @tag.errors, status: :unprocessable_content }
      end
    end
  end

  # DELETE /tags/1 or /tags/1.json
  def destroy
    @tag.destroy!

    respond_to do |format|
      format.html { redirect_to tags_path, status: :see_other, notice: "Tag was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_tag
      @tag = Current.user.tags.find(params.expect(:id))
    end

    # Only allow a list of trusted parameters through.
    def tag_params
      params.expect(tag: [ :name, :favorite ])
    end
end
