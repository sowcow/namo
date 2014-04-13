require 'slim'
require 'sass'
require 'kramdown'
 
Slim::Engine.set_default_options pretty: true
 
slim = <<slim
doctype 5
html
  head
    meta charset='utf-8'

    sass:
      i
        font-style: normal

    / stuff
    sass:
      h1
        //font-family: Arial
        //font-family: Verdana, Geneva, Tahoma, sans-serif
        font-family: source-sans-pro, 'Helvetica Neue', Helvetica, Arial, sans-serif
      h2
        color: silver
      td, h1
        text-align: center
      td:first-child
        font-size: 150%
     
    / theme
    sass:
      html
        //$c: #9c9
        //$x: 50%
        //$y: 100% - $x
        //$y: 90%
        //$c: mix(orange, gray, $x)
        //$c: mix($c, white, $y)
        //background-color: $c

        //background-color: #333
        //color: #bbb
        $te: mix(silver, teal, 25%)
        a
          color: $te


        //background-color: #666666
        //background-color: #c63
        //-webkit-background-clip: text
        //-moz-background-clip: text
        //background-clip: text
        //color: transparent
        //text-shadow: rgba(255,255,255,0.5) 0px 3px 3px

    / basic look
    sass:
      body
        margin: 0
      body > p
        $x: 64px
        margin-left: $x
        margin-right: $x

      *
        font-family: monospace
        //font-family: sans-serif
      td
        padding: 5px 10px
        p
          margin: 0
          padding: 0
      table
        $b: solid 1px mix(teal, silver)
        border-top: $b
        border-bottom: $b
        box-shadow: 0 0 10px silver
        padding-bottom: 16.185px
        margin-bottom: 16.185px
        margin-top: 16.185px
        /* text specific... */

  body
    == self
    coffee:
      data = Data
      chars = document.querySelectorAll 'i'
      hi = 'orange'

      enter = ->
        id = @getAttribute 'x-id'
        links = data.linksBySource[id]
        return unless links
        targets = []

        for link in links

          targets = data.targetsByLink[link]
          for id in targets
            find = document.querySelectorAll(
              "i[x-id='\#{id}']"
            )
            found = find[0]
            found.style.color = hi

          sources = data.sourcesByLink[link]
          for id in sources
            find = document.querySelectorAll(
              "i[x-id='\#{id}']"
            )
            found = find[0]
            found.style.color = hi


      exit = ->
        for one in chars
          if one.style.color is hi
            one.style.color = null

      for one in chars
        one.onmouseover = enter
        one.onmouseout = exit
slim
layout = Slim::Template.new { slim }
 
 
task :default do
  input = 'input.md'
  output = 'output.html'
   
  markdown = File.read input
  body = AlignedText.new(markdown).to_html
  html = layout.render body
   
  File.write output, html
end

class Markdown
  def initialize(md) @markdown = md end

  private
  def nodes
    @nodes ||= root.children
  end
  def root
    @root ||= doc.root
  end
  def doc
    @doc ||= Kramdown::Document.new @markdown
  end
end

class AlignedText < Markdown
  def to_html
    preprocess
    data = [
      '<script type="text/javascript">',
      "window.Data = #{the_data};",
      '</script>'
    ].join
    [doc.to_html, data] * ?\n
  end

  def the_data
    text = @index.text
    puts '---'
    puts text

    links = []
    @pairs.each { |from, to|
      m = text.match /#{from}/
      next unless m
      i = m.begin 0
      j = m.end(0) - 1
      from_ids = [*i..j]

      m = text.match /#{to}/
      next unless m
      i = m.begin 0
      j = m.end(0) - 1
      to_ids = [*i..j]

      links << [from_ids, to_ids]
    }
    link_by_src = {}
    target_by_link = {}
    source_by_link = {}
    links.each_with_index { |(from,to),i|
      from.each { |id|
        link_by_src[id] ||= []
        link_by_src[id] << i
        link_by_src[id].uniq!

        source_by_link[i] ||= []
        source_by_link[i] << id
        source_by_link[i].uniq!
      }
      to.each { |id|
        target_by_link[i] ||= []
        target_by_link[i] << id
        target_by_link[i].uniq!
      }
    }
    data = { linksBySource: link_by_src,
             targetsByLink: target_by_link,
             sourcesByLink: source_by_link }

    require 'json'
    JSON.dump data
  end


  private
  def preprocess
    replace =
      nodes.select { |node| node.type == :codeblock }.
        each_with_object({}) { |node, hash|
          block = AlignedBlock.new(node.value)
          hash[node] = block.node
          @pairs = block.data
          @index = block.index
        }
    replace.each_pair { |from, to|
      nodes[nodes.index from] = to
    }
  end
end

class AlignedBlock < Markdown
  def node
    table
  end

  def rows
    num = 0
    all = []
    row = nil

    nodes.reject { |x| x.type == :blank }
    .each { |node|
      num += 1

      case num
      when 3
        if node.type == :table
          #puts '---'
          rows = node.children.first.children
          rows.map! { |x|
            x.children.map { |x| x.children.first.value }
          }
          #puts rows.inspect
          @data ||= []
          @data << rows
          num = 0; next
          # ignore for now
        else
          num = 0; redo
        end
      when 1
        row = [node]
      when 2
        row << node
        all << row
      else raise "wut? #{num}" end
    }
    all
    #  each_slice(2).to_a
    #nodes.reject { |x|
    #  x.type == :blank
    #}.each_slice(2).to_a
  end

  def data
    @data.flatten 1
  end

  def index
    if @index
      @index
    else
      @index = Enumerator.new { |x|
        i = 0
        loop do
          x << i 
          #"n#{i}"
          i += 1
        end
      }
      def @index.text
        @text ||= ''
      end
      index
    end
  end

  # nice task to seperate decisions and dependencies t*do
  def table rows = rows

    tbody = Kramdown::Element.new :tbody
    rows.each { |row|
      tr = Kramdown::Element.new :tr
      row.each { |col|
        #text = Kramdown::Element.new :text, col
        col = index_letters col, index
        td = Kramdown::Element.new :td
        td.children << col
        tr.children << td
      }
      tbody.children << tr
    }

    table = Kramdown::Element.new :table
    table.options[:alignment] = :default
    table.children << tbody

    #puts index.text
    table
  end

  private
  def index_letters node, index
    #puts node.inspect
    got = case node.type
    when :text
      text = node.value

      new = Kramdown::Element.new :html_element, 'span'
      new.options[:category] = :span
      new.options[:content_model] = :span

      new.children = text.chars.map { |char|
        span = Kramdown::Element.new :html_element, 'i'
        span.options[:category] = :span
        span.options[:content_model] = :span
        span.attr['x-id'] = index.next
        index.text << char

        text = Kramdown::Element.new :text, char
        span.children = [text]
        span
      } #.flatten
      new
    else
      if node.children
        node.children = node.children.map { |x|
          index_letters x, index
        }
      end
      node
    end
    #puts '---'
    #puts got.inspect
    got
  end
end
