class QualificationsController < ApplicationController
  # GET /qualifications
  # GET /qualifications.xml
  def index
    @qualifications = Qualification.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @qualifications }
    end
  end

  # GET /qualifications/1
  # GET /qualifications/1.xml
  def show
    @qualification = Qualification.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @qualification }
    end
  end

  # GET /qualifications/new
  # GET /qualifications/new.xml
  def new
    @qualification = Qualification.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @qualification }
    end
  end

  # GET /qualifications/1/edit
  def edit
    @qualification = Qualification.find(params[:id])
  end

  # POST /qualifications
  # POST /qualifications.xml
  def create
    @qualification = Qualification.new(params[:qualification])

    respond_to do |format|
      if @qualification.save
        flash[:notice] = 'Qualification was successfully created.'
        format.html { redirect_to(@qualification) }
        format.xml  { render :xml => @qualification, :status => :created, :location => @qualification }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @qualification.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /qualifications/1
  # PUT /qualifications/1.xml
  def update
    @qualification = Qualification.find(params[:id])

    respond_to do |format|
      if @qualification.update_attributes(params[:qualification])
        flash[:notice] = 'Qualification was successfully updated.'
        format.html { redirect_to(@qualification) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @qualification.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /qualifications/1
  # DELETE /qualifications/1.xml
  def destroy
    @qualification = Qualification.find(params[:id])
    @qualification.destroy

    respond_to do |format|
      format.html { redirect_to(qualifications_url) }
      format.xml  { head :ok }
    end
  end
end
