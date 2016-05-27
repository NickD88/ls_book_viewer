require "sinatra"
require "sinatra/reloader" if development?
require "tilt/erubis"

before do
    @contents = File.readlines "data/toc.txt"
end

helpers do
  def in_paragraphs(text)
    text.split("\n\n").each_with_index.map do |paragraph, idx|
      "<p id=section#{idx}>#{paragraph}</p>"
    end.join
  end

  def highlight_search(string, search_value)
    string.gsub(search_value, %(<strong>#{search_value}</strong>))
  end
end

not_found do
  redirect "/"
end


get "/" do
  @title = "The Adventures of Sherlock Holmes"
  erb :home
end

get "/chapters/:number" do
  number = params[:number].to_i
  chapter_name = @contents[number - 1]
  @title = "Chapter #{number} - #{chapter_name}"
  @chapter = File.read "data/chp#{number}.txt"

  erb :chapter
end

get "/search" do
#  @results = @contents.each { |chapter| chapter.include?(params[:query])}
  if params[:query]
    @results = @contents.each_with_index.each_with_object([]) do | (chapter, idx), results |
      text = File.read("data/chp#{idx + 1}.txt")
      paragraphs = text.split("\n\n")
      paragraphs.each_with_index do |paragraph, paragraph_index|
        if paragraph.include?(params[:query])
          results << [chapter, idx, paragraph, paragraph_index]
        end
      end
    end
  end

  erb :search
end
