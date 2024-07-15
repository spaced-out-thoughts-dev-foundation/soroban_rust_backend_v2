require 'spec_helper'

RSpec.describe SorobanRustBackend::ContractHandler do
  describe '.generate' do
    context 'when stellar example' do
      context 'when hello world contract' do
        let(:contract_name) { 'HelloWorldContract' }
        let(:contract_state) { nil }
        let(:contract_user_defined_types) { nil }
        let(:contract_interface) do
          [
            DTRCore::Function.new(
              'hello',
              [
                { name: 'env', type_name: 'Env' },
                { name: 'to', type_name: 'String' }
              ],
              'List<String>',
              [
                ins(instruction: 'instantiate_object', inputs: ['List', 'env', '"Hello"', 'to'], assign: 'Thing_to_return', scope: 0,
                    id: 0),
                ins(instruction: 'return', inputs: ['Thing_to_return'], scope: 0, id: 1)
              ]
            )
          ]
        end
        let(:contract_helpers) {}
        let(:contract_non_translatables) { nil }

        let(:contract) do
          DTRCore::Contract.new(
            contract_name,
            contract_state,
            contract_interface,
            contract_user_defined_types,
            contract_helpers,
            contract_non_translatables
          )
        end

        let(:expected_output) do
          <<~RUST
            #![no_std]
            use soroban_sdk::{contract, contractimpl, Env, String, Vec, vec, auth::Context, IntoVal, unwrap::UnwrapOptimized};

            #[contract]
            pub struct HelloWorldContract;

            #[contractimpl]
            impl HelloWorldContract {
                pub fn hello(env: Env, to: String) -> Vec<String> {
                    let Thing_to_return: Vec<String>;
                    let mut Thing_to_return = vec![env, "Hello", to];
                    return Thing_to_return;

                }
            }
          RUST
        end

        it 'generates the correct contract' do
          expect(described_class.generate(contract)).to eq(expected_output)
        end
      end

      context 'when errors contract' do
        let(:contract_name) { 'IncrementContract' }
        let(:contract_state) do
          [
            DTRCore::State.new(
              'COUNTER',
              'Symbol',
              '"COUNTER"'
            ),
            DTRCore::State.new(
              'MAX',
              'Integer',
              '5'
            )
          ]
        end
        let(:contract_user_defined_types) do
          [
            DTRCore::UserDefinedType.new(
              'Error_ENUM',
              [
                { name: 'LimitReached', type: '1' }
              ]
            )
          ]
        end
        let(:contract_interface) do
          [
            DTRCore::Function.new(
              'hello',
              [
                { name: 'env', type_name: 'Env' },
                { name: 'to', type_name: 'String' }
              ],
              'Result<i128, Error>',
              [
                ins(instruction: 'evaluate', inputs: ['env.storage'], assign: 'METHOD_CALL_EXPRESSION_6', scope: 0,
                    id: 9),
                ins(instruction: 'evaluate', inputs: ['METHOD_CALL_EXPRESSION_6.instance'],
                    assign: 'METHOD_CALL_EXPRESSION_5', scope: 0, id: 10),
                ins(instruction: 'evaluate', inputs: ['METHOD_CALL_EXPRESSION_5.get', 'COUNTER'],
                    assign: 'METHOD_CALL_EXPRESSION_2', scope: 0, id: 11),
                ins(instruction: 'evaluate', inputs: ['METHOD_CALL_EXPRESSION_2.unwrap_or', '0'],
                    assign: 'count|||Integer', scope: 0, id: 12),
                ins(instruction: 'print', inputs: ['env', '"count: {}"', 'count'], scope: 0, id: 13),
                ins(instruction: 'add', inputs: %w[count 1], assign: 'count', scope: 0, id: 18),
                ins(instruction: 'evaluate', inputs: %w[less_than_or_equal_to count MAX],
                    assign: 'CONDITIONAL_JUMP_ASSIGNMENT_19', scope: 0, id: 24),
                ins(instruction: 'jump', inputs: %w[CONDITIONAL_JUMP_ASSIGNMENT_19 25], scope: 0, id: 26),
                ins(instruction: 'jump', inputs: ['44'], scope: 0, id: 45),
                ins(instruction: 'evaluate', inputs: ['env.storage'], assign: 'METHOD_CALL_EXPRESSION_32', scope: 25,
                    id: 35),
                ins(instruction: 'evaluate', inputs: ['METHOD_CALL_EXPRESSION_32.instance'],
                    assign: 'METHOD_CALL_EXPRESSION_31', scope: 25, id: 36),
                ins(instruction: 'evaluate', inputs: ['METHOD_CALL_EXPRESSION_31.set', 'COUNTER', 'count'],
                    assign: 'METHOD_CALL_EXPRESSION_31', scope: 25, id: 37),
                ins(instruction: 'evaluate', inputs: %w[Ok count], assign: 'Thing_to_return', scope: 25, id: 42),
                ins(instruction: 'jump', inputs: ['0'], scope: 25, id: 43),
                ins(instruction: 'evaluate', inputs: ['Err', 'Error::LimitReached'], assign: 'Thing_to_return',
                    scope: 44, id: 50),
                ins(instruction: 'jump', inputs: ['0'], scope: 44, id: 51),
                ins(instruction: 'return', inputs: ['Thing_to_return'], scope: 0, id: 0)
              ]
            )
          ]
        end
        let(:contract_helpers) { nil }
        let(:contract_non_translatables) { nil }

        let(:contract) do
          DTRCore::Contract.new(
            contract_name,
            contract_state,
            contract_interface,
            contract_user_defined_types,
            contract_helpers,
            contract_non_translatables
          )
        end

        let(:expected_output) do
          <<~RUST
            #![no_std]
            use soroban_sdk::{contract, contracterror, Symbol, symbol_short, contractimpl, Env, String, log, auth::Context, IntoVal, unwrap::UnwrapOptimized};

            #[contracterror]
            #[derive(Copy, Clone, Debug, Eq, PartialEq, PartialOrd, Ord)]
            pub enum Error {
                LimitReached = 1,
            }

            const COUNTER: Symbol = symbol_short!("COUNTER");
            const MAX: i128 = 5;
            #[contract]
            pub struct IncrementContract;

            #[contractimpl]
            impl IncrementContract {
                pub fn hello(env: Env, to: String) -> Result<i128, Error> {
                    let Thing_to_return: Result<i128, Error>;
                    let mut METHOD_CALL_EXPRESSION_6 = env.storage();
                    let mut METHOD_CALL_EXPRESSION_5 = METHOD_CALL_EXPRESSION_6.instance();
                    let mut METHOD_CALL_EXPRESSION_2 = METHOD_CALL_EXPRESSION_5.get(COUNTER);
                    let mut count: i128 = METHOD_CALL_EXPRESSION_2.unwrap_or(0);
                    log!(env, "count: {}", count);
                    count = count + 1;
                    let CONDITIONAL_JUMP_ASSIGNMENT_19 = count <= MAX;
                    if CONDITIONAL_JUMP_ASSIGNMENT_19 {
                        let mut METHOD_CALL_EXPRESSION_32 = env.storage();
                        let mut METHOD_CALL_EXPRESSION_31 = METHOD_CALL_EXPRESSION_32.instance();
                        let mut METHOD_CALL_EXPRESSION_31 = METHOD_CALL_EXPRESSION_31.set(COUNTER, count);
                        Thing_to_return = Ok(count);
                    }
                    else {
                        Thing_to_return = Err(Error::LimitReached);
                    }
                    return Thing_to_return;

                }
            }
          RUST
        end

        it 'generates the correct contract' do
          expect(described_class.generate(contract)).to eq(expected_output)
        end
      end
    end
  end
end
