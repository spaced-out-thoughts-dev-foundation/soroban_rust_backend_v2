module SorobanRustBackend
  class ContractCodeGenerator
    def initialize(content)
      @dtr_contract = ::DTRCore::Contract.from_dtr_raw(content)
    end

    def generate
      @content = ''

      @content += dtr_contract.non_translatables if dtr_contract.non_translatables
      generate_user_defined_types
      generate_state
      generate_contract_name
      generate_interface
      generate_helpers

      generate_contract_header

      @content
    end

    def self.generate_from_file(file_path)
      new(File.read(file_path)).generate
    end

    def self.generate_from_string(dtr_string)
      new(dtr_string).generate
    end

    private

    attr_reader :dtr_contract

    def generate_contract_header
      imports_super_set = %w[
        Address
        BytesN
        contract
        contractimpl
        contracttype
        contracterror
        symbol_short
        vec
        Env
        Symbol
        Vec
        Val
        log
        token
      ]

      used_imports = []

      @content.split.each do |word|
        imports_super_set.each do |import|
          used_imports << import if word.include?(import)
        end
      end

      used_imports.uniq!

      # TODO: unsure how to check this one
      used_imports << 'auth::Context'
      used_imports << 'IntoVal'
      used_imports << 'unwrap::UnwrapOptimized'

      # TODO: don't hardcode imports
      @content = "#![no_std]\nuse soroban_sdk::{#{used_imports.join(', ')}};\n\n" + @content
    end

    def generate_contract_name
      @content += "#[contract]\npub struct #{dtr_contract.name};\n\n"
    end

    def generate_state; end

    def generate_user_defined_types
      return if dtr_contract.user_defined_types.nil?

      dtr_contract.user_defined_types.each do |udt|
        @content += SorobanRustBackend::UserDefinedTypes::Handler.generate(udt)
      end
    end
  end
end
