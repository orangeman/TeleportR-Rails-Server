class PlacesController < ApplicationController

	$BUS = 2**0
	$TRAM = 2**1
	$UBAHN = 2**2
	$SBAHN = 2**3
	$ZUG = 2**4
	$BOOT = 2**5
	$STREET = 2**6



  def nearby
    @places = Place.find_by_sql "SELECT name, modes, ST_AsKML(latlon) AS latlon
    							 FROM places 
    							 WHERE ST_DWithin(ST_GeomFromEWKT('SRID=4326;POINT
    							 (#{params[:lon]} #{params[:lat]})'), latlon, 0.134)
    							 AND modes!=64;"

    respond_to do |format|
      format.html { render :index }
      format.xml  { render :xml => @places }
      format.kml  { render :index, :layout => false } 
    end
  end
  

  def streets
    @places = Place.find_by_sql "SELECT name, modes, ST_AsKML(latlon) AS latlon
    							 FROM places 
    							 WHERE modes=64 
    							 #{if params[:state_id]
    							  	"AND state_id="+params[:state_id] 
    							  end}
    							 ORDER BY name;"

    respond_to do |format|
      format.html { render :index }
      format.xml  { render :xml => @places }
      format.kml  { render :layout => false } 
    end
  end
  

  def stations
    @places = Place.find_by_sql "SELECT name, modes, ST_AsKML(latlon) AS latlon
    							 FROM places 
    							 WHERE modes!=64 
    							 #{if params[:state_id]
    							  	"AND state_id="+params[:state_id] 
    							  end}
    							 ORDER BY name;"

    respond_to do |format|
      format.html { render :index }
      format.xml  { render :xml => @places }
      format.kml  { render :index, :layout => false } 
    end
  end

  # GET /places/1
  # GET /places/1.xml
  def show
    @place = Place.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @place }
    end
  end

  # GET /places/new
  # GET /places/new.xml
  def new
    @place = Place.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @place }
    end
  end

  # GET /places/1/edit
  def edit
    @place = Place.find(params[:id])
  end

  # POST /places
  # POST /places.xml
  def create
    @place = Place.new(params[:place])

    respond_to do |format|
      if @place.save
        flash[:notice] = 'Place was successfully created.'
        format.html { redirect_to(@place) }
        format.xml  { render :xml => @place, :status => :created, :location => @place }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @place.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /places/1
  # PUT /places/1.xml
  def update
    @place = Place.find(params[:id])

    respond_to do |format|
      if @place.update_attributes(params[:place])
        flash[:notice] = 'Place was successfully updated.'
        format.html { redirect_to(@place) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @place.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /places/1
  # DELETE /places/1.xml
  def destroy
    @place = Place.find(params[:id])
    @place.destroy

    respond_to do |format|
      format.html { redirect_to(places_url) }
      format.xml  { head :ok }
    end
  end
end
