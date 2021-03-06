module JsTestCore
  module Resources
    class File < Resource
      map "*"

      MIME_TYPES = {
        '.html' => 'text/html',
        '.htm' => 'text/html',
        '.js' => 'text/javascript',
        '.css' => 'text/css',
        '.png' => 'image/png',
        '.jpg' => 'image/jpeg',
        '.jpeg' => 'image/jpeg',
        '.gif' => 'image/gif',
        }

      get "*" do
        do_get
      end
      
      def relative_path
        @relative_path ||= request.path_info
      end

      def absolute_path
        @absolute_path ||= ::File.expand_path("#{public_path}#{relative_path}")
      end

      protected

      def do_get
        if ::File.exists?(absolute_path)
          if ::File.directory?(absolute_path)
            render_dir
          else
            render_file
          end
        else
          pass
        end
      end

      def render_dir
        Representations::Dir.new(:relative_path => relative_path, :absolute_path => absolute_path).to_s
      end

      def render_file
        extension = ::File.extname(absolute_path)
        content_type = MIME_TYPES[extension] || 'text/html'
        [
          200,
          {
            'Content-Type' => content_type,
            'Last-Modified' => ::File.mtime(absolute_path).rfc822
          },
          ::File.read(absolute_path)
        ]
      end
    end
  end
end
