class ProjectsController < ApplicationController
  #Verify that every action is 'authorized', otherwise throw an exception
  check_authorization
  #Will automatically do the equivalent of 'set project' for us
  load_resource
  #Will perform 'authorize! action_name, @project' for all the basic actions
  #We can manually call authorize! in any non-RESTful actions we make, using one of the restful actions as its check
  authorize_resource only: Ability::RESTFUL_ACTIONS


  respond_to :html, :json

  def index
    @projects = Project.all
  end

  def new
    @project = Project.new
    respond_with(@project)
  end

  def create
    @project = Project.new(project_params)

    @project.author= current_user

    respond_to do |format|
      if @project.save
        format.html { redirect_to @project, notice: 'Project was successfully created' }
        format.json { render :show, status: :created, location: @project }
      else
        format.html { render :new }
        format.json { render json: @project.errors, status: :unprocessable_entity }
      end
    end

  end

  def like
    authorize! :create, ProjectLike
    result = @project.add_like(current_user)
    respond_to do |format|
      format.html do
        redirect_to project_path(@project)
      end
    end
  end

  def unlike
    authorize! :destroy, ProjectLike
    result = @project.remove_like(current_user)
    respond_to do |format|
      format.html do
        redirect_to project_path(@project)
      end
    end
  end

  def show
    @liked = current_user && @project.liking_users.include?(current_user)
    @comments = @project.root_comments
    if params[:comment_id]
      @comments = [@project.comments.find(params[:comment_id])]
    end

    @related_works = [
        OpenStruct.new(
            {
                title: 'A Graphic Design Item',
                thumbnail: '/solid/img/portfolio/portfolio_09.jpg',
                url: '/solid/single-project.html'
            }),
        OpenStruct.new(
            {
                title: 'A Web Design Item',
                thumbnail: '/solid/img/portfolio/portfolio_02.jpg',
                url: '/solid/single-project.html'
            }),
        OpenStruct.new(
            {
                title: 'A Graphic Design Item',
                thumbnail: '/solid/img/portfolio/portfolio_03.jpg',
                url: '/solid/single-project.html'
            }),
        OpenStruct.new(
            {
                title: 'A Graphic Design Item',
                thumbnail: '/solid/img/portfolio/portfolio_04.jpg',
                url: '/solid/single-project.html'
            }),
        OpenStruct.new(
            {
                title: 'A Graphic Design Item',
                thumbnail: '/solid/img/portfolio/portfolio_05.jpg',
                url: '/solid/single-project.html'
            })
    ]
  end

  def edit
  end

  def update
    flash[:notice] = "#{@project.title} was successfully updated." if @project.update(project_params)
    respond_with(@project)
  end

  def destroy
    @project.destroy
    flash[:notice] = "#{@project.title} was successfully destroyed."
    respond_with @project
  end

  private

  def project_params
    params.require(:project).permit(:title, :instructions, :about, :thumbnail)
  end

end
