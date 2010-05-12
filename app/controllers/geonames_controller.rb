class GeonamesController < ApplicationController
  # GET /geonames
  # GET /geonames.xml
  def index
    @geonames = Geoname.find_by_sql "SELECT *
    							 FROM geonames 
    							 #{if params[:country_id]
    							  	"WHERE geonames.country_code = (SELECT country_code FROM countries
    							  		WHERE id="+params[:country_id]+") 
    							  	 AND feature_code='PPLX' AND admin1='02'"
    							  end}
    							 ORDER BY name LIMIT 420;"

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @geonames }
    end
  end

  # GET /geonames/1
  # GET /geonames/1.xml
  def show
    @geoname = Geoname.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @geoname }
    end
  end

  # GET /geonames/new
  # GET /geonames/new.xml
  def new
    @geoname = Geoname.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @geoname }
    end
  end

  # GET /geonames/1/edit
  def edit
    @geoname = Geoname.find(params[:id])
  end

  # POST /geonames
  # POST /geonames.xml
  def create
    @geoname = Geoname.new(params[:geoname])

    respond_to do |format|
      if @geoname.save
        flash[:notice] = 'Geoname was successfully created.'
        format.html { redirect_to(@geoname) }
        format.xml  { render :xml => @geoname, :status => :created, :location => @geoname }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @geoname.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /geonames/1
  # PUT /geonames/1.xml
  def update
    @geoname = Geoname.find(params[:id])

    respond_to do |format|
      if @geoname.update_attributes(params[:geoname])
        flash[:notice] = 'Geoname was successfully updated.'
        format.html { redirect_to(@geoname) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @geoname.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /geonames/1
  # DELETE /geonames/1.xml
  def destroy
    @geoname = Geoname.find(params[:id])
    @geoname.destroy

    respond_to do |format|
      format.html { redirect_to(geonames_url) }
      format.xml  { head :ok }
    end
  end
end
