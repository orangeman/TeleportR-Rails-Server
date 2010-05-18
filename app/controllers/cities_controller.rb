class CitiesController < ApplicationController
  # GET /cities
  # GET /cities.xml
  def index
  
	 @cities = City.find_by_sql "SELECT id, name, country_iso, population, timezone, ST_AsKML(latlon) AS latlon
    							 FROM geonames 
    							 WHERE type='City'
    							 #{if params[:state_id]
    							  	"AND state_id="+params[:state_id]
    							   elsif params[:country_id]
    							  	"AND country_iso='"+params[:country_id].upcase+"'"
    							   end}
    							 ORDER BY population DESC LIMIT 2342;"

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @cities }
    end
  end

  # GET /cities/1
  # GET /cities/1.xml
  def show
    @city = City.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @city }
    end
  end

  # GET /cities/new
  # GET /cities/new.xml
  def new
    @city = City.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @city }
    end
  end

  # GET /cities/1/edit
  def edit
    @city = City.find(params[:id])
  end

  # POST /cities
  # POST /cities.xml
  def create
    @city = City.new(params[:city])

    respond_to do |format|
      if @city.save
        flash[:notice] = 'city was successfully created.'
        format.html { redirect_to(@city) }
        format.xml  { render :xml => @city, :status => :created, :location => @city }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @city.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /cities/1
  # PUT /cities/1.xml
  def update
    @city = City.find(params[:id])

    respond_to do |format|
      if @city.update_attributes(params[:city])
        flash[:notice] = 'city was successfully updated.'
        format.html { redirect_to(@city) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @city.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /cities/1
  # DELETE /cities/1.xml
  def destroy
    @city = City.find(params[:id])
    @city.destroy

    respond_to do |format|
      format.html { redirect_to(cities_url) }
      format.xml  { head :ok }
    end
  end
end
