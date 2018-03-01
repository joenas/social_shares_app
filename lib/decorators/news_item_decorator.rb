class NewsItemDecorator < Draper::Decorator
  delegate_all

  EMPTY = ''.freeze

  def to_h
    {
      id: id,
      link: link,
      image: image,
      source: source,
      title: title,
      description: description,
      date: date,
      content_html: content_html,
      content_truncated: content_truncated
    }
  end

  def source
    object.source.name
  end

  def link
    url
  end

  def date
    published_at.strftime("%a, %b %d %Y %H:%M")
  end

  def content_html
    content
  end

  def content_truncated
    content
      .gsub(/<script.*?<\/script>/m, EMPTY).gsub(/<!--.*?-->/m, EMPTY).gsub(/<style.*?<\/style>/m, EMPTY).gsub(/<.*?>/m, EMPTY)
      .truncate_words(30).squish
  end

end
