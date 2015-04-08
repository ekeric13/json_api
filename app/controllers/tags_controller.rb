class TagsController < ApplicationController
  skip_before_action :verify_authenticity_token
  def create
    content_type :json

    # Search for the entity first, and if it exists then delete it
    tag = Tag.where(entity_type: params[:entity_type], entity_id:  params[:entity_id])
    if tag.present?
      tag.destroy(tag[0][:id])
    end

    # create a new tag
    @new_tag = Tag.new(tag_params)
    if new_tag.save
      status 201
      @new_tag.to_json
    else
      status 500
      { error: 'Could not POST tag request. Possible validation error. Need to have "tags" as an array, "entity_id" as a string, and "entity_type" as a string.' }.to_json
    end
  end

  def show
    content_type :json
    @tag = Tag.where(entity_type: params[:entity_type], entity_id:  params[:entity_id])

    if @tag
      status 201
      @tag.to_json
    else
      status 404
      { error: 'Could not GET tag request. Possibily wrong entity_id or entity_type' }.to_json
    end
  end

  def delete
    content_type :json
    tag = Tag.where(entity_type: params[:entity_type], entity_id:  params[:entity_id])

    if tag.destroy
      {:success => "ok"}.to_json
    else
      status 500
      { error: 'Could not DELETE tag. Possibly wrong entity_id or entity_type' }.to_json
    end
  end


  def stats
    content_type :json
    tags = Tag.where(entity_type: params[:entity_type], entity_id:  params[:entity_id]) || Tag.all
    # tags = [{entity_type: 'string of entity type', entity_id: 'string_id_1234', tags: ['string_tag1', 'string_tag2']}]
    tag_array = []
    tag_stats = []

    tags.each do |tag|
      tag_array << tag['tags']
    end
    # tag_array = [['string_tag1', 'string_tag2'], ['string_tag1', 'string_tag2']]

    tag_array.flatten
    # tag_array = ['string_tag1', 'string_tag2', 'string_tag1', 'string_tag2']

    def tag_exists(tag)
      # if tag_stats is empty return false
      if tag_stats == []
        current_tag = [false]
      else
        tag_stats.each do |tag_hash|
          if tag_hash['tag'] == tag
            # if tag exists return true and the tag
            current_tag = [true, tag_hash]
          else
            # if tag does not exist return false
            current_tag = [false]
          end
        end
      end
    end

    tag_array.each do |specific_tag|
      tag_exists(specific_tag)
      if current_tag[0]
        current_tag[1]['count'] += 1
      else
        tag_stats << {'tag' => specific_tag, 'count'=> 1}
      end
    end
    # tag_stats = [{tag: 'Bike', count: 5}, {tag: 'Pink', count: 3}]

    if tag_stats
      status 201
      tag_stats
    else
      status 404
      { error: 'Could not GET stats of tag. Possibly wrong entity_id or entity_type' }.to_json
    end
  end

  private

   def tag_params
     params.require(:tag).permit(:tags, :entity_type, :entity_id)
   end

end
