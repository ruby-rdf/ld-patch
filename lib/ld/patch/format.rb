module LD::Patch
  ##
  # LD::Patch format specification. Note that this format does not define any readers or writers.
  #
  # @example Obtaining an LD Patch format class
  #     RDF::Format.for(:ldp)           #=> LD::Patch::Format
  #     RDF::Format.for("etc/foaf.ldp")
  #     RDF::Format.for(:file_name         => "etc/foaf.ldp")
  #     RDF::Format.for(file_extension: "ldp")
  #     RDF::Format.for(:content_type   => "text/ldpatch")
  #
  # @see http://www.w3.org/TR/ldpatch/
  class Format < RDF::Format
    content_type     'text/ldpatch', extension: :ldp
    content_encoding 'utf-8'

    ##
    # Hash of CLI commands appropriate for this format
    # @return [Hash{Symbol => Lambda(Array, Hash)}]
    def self.cli_commands
      {
        patch: {
          description: "Patch the current graph using a URI Encoded patch file, or a referenced path file/URI",
          help: "patch [--patch 'patch'] [--patch-file file]",
          parse: true,
          lambda: -> (argv, opts) do
            opts[:patch] ||= RDF::Util::File.open_file(opts[:patch_file]) {|f| f.read}
            raise ArgumentError, "Patching requires a URI encoded patch or reference to patch resource" unless opts[:patch]
            $stdout.puts "Patch"
            patch = LD::Patch.parse(opts[:patch], base_uri: opts.fetch(:patch_file, "http://rubygems.org/gems/ld-patch"))
            RDF::CLI.repository.query(patch)
          end,
          options: [
            RDF::CLI::Option.new(
              symbol: :patch,
              datatype: String,
              on: ["--patch STRING"],
              description: "Patch in URI encoded format"
            ) {|v| URI.decode(v)},
            RDF::CLI::Option.new(
              symbol: :patch_file,
              datatype: String,
              on: ["--patch-file URI"],
              description: "URI of patch file"
            ) {|v| RDF::URI(v)},
          ]
        }
      }
    end

    def self.to_sym; :ldpatch; end
  end
end
