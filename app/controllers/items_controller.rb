class ItemsController < ApplicationController
  require_role "admin", :for => [:publish,:draft, :feature, :unfeature,:destroy] # don't allow contractors to destroy
  require_role "author", :only => [:edit,:preview,:new,:create,:index,:update]
  def index
   
    @items = Item.paginate :page => params[:page], :per_page => 8, :order =>"id desc"
    render :layout => "admin"
    
  end

  def edit
    @pages = Page.all
    @item = Item.find(params[:id])

  end

  def new

    @pages = Page.all
    @item = Item.new

  end
  def create
    @item = Item.new(params[:item])
    @page = Page.find(@item.page_id)
    respond_to do |format|
      if @item.save
        flash[:notice] = 'Page was successfully created.'
        format.html { redirect_to(:controller=>:pages, :action=>:show,:id=>@page.name) }
        format.xml  { render :xml => @item, :status => :created, :location => @item }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @item.errors, :status => :unprocessable_entity }
      end
    end
  end
  def show
    @item = Item.find(params[:id],:conditions => "state = 'published'")
    @comment = Comment.new
  end

  def preview
    @item = Item.find(params[:id])
    @comment = Comment.new
  end

  def find
    @items = Item.tagged_with(params[:id], :on => :tags,:conditions => "state = 'published'").by_date
  end

  def feature
    @item = Item.find(params[:id])
    @items = Item.all
    @items.each do |i|
      i.unfeature!
    end
    @item.feature!
    redirect_to(:controller=>:items)
  end

  def publish
     @item = Item.find(params[:id])
     @item.publish!
     redirect_to :controller => :items
  end

  def draft
     @item = Item.find(params[:id])
     @item.draft!
     redirect_to :controller => :items
  end

  def update
    @item = Item.find(params[:id])

    respond_to do |format|
      if @item.update_attributes(params[:item])
        flash[:notice] = 'Item was successfully updated.'
        format.html { redirect_to :controller => :welcome }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @item.errors, :status => :unprocessable_entity }
      end
    end
  end
  def comment
    @item  = Item.find(params[:id])
    @item.add_comment Comment.new(params[:comment])
    redirect_to :controller => :items, :action => :show, :id => params[:id]
  end
  def destroy
    @item = Item.find(params[:id])
    @item.destroy

    respond_to do |format|
      format.html { redirect_to("#{items_url}")}
      format.xml  { head :ok }
    end
  end
end
