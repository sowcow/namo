require 'slim'
require 'kramdown'
 
Slim::Engine.set_default_options pretty: true
 
slim = <<slim
doctype 5
html
  head
    meta charset='utf-8'
  body
    == self
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
    doc.to_html
  end

  private
  def preprocess
    replace =
      nodes.select { |node| node.type == :codeblock }.
        each_with_object({}) { |node, hash|
          hash[node] = AlignedBlock.new(node.value).node
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

  # nice task to seperate decisions and dependencies t*do
  def table rows = rows

    tbody = Kramdown::Element.new :tbody
    rows.each { |row|
      tr = Kramdown::Element.new :tr
      row.each { |col|
        #text = Kramdown::Element.new :text, col
        td = Kramdown::Element.new :td
        td.children << col
        tr.children << td
      }
      tbody.children << tr
    }

    table = Kramdown::Element.new :table
    table.options[:alignment] = :default
    table.children << tbody
    table

  end
end
__END__
        

      if node.type == :codeblock
        puts node.inspect
      end
    }
    #  next if node.type == :blank

    #  if node.type == :hr
    #    @pairs = !!! @pairs
    #    nodes.delete node

    #    @num = 0; next
    #  end

    #  next unless @pairs
    #  @num += 1 # ok for now
    #           # but things may be structured another way
    #           # not sure what way is better for the future

    #  # tables
    #  if @pairs && @num == 3 && node.type == :table
    #    #require 'pp'
    #    #puts '-----'
    #    #pp node
    #    #p node.class
    #    nodes.delete node

    #    @num = 0; next
    #  end

    #  @num = 1 if @num == 3 # not a table
    #                        # not gona nest if/else now

    #  # non tables
    #  if @pairs
    #    case @num 
    #    when 1
    #    when 2
    #      #nodes.delete node
    #    else raise 'not possible' end
    #  end
    #}
  end

end