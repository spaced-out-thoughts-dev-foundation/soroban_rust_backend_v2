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

      context 'when atomic multiswap contract' do
        let(:contract_name) { 'AtomicMultiSwapContract' }
        let(:contract_state) { nil }
        let(:contract_user_defined_types) do
          [
            DTRCore::UserDefinedType.new(
              'SwapSpec_STRUCT',
              [
                { name: 'address', type: 'Address' },
                { name: 'amount', type: 'BigInteger' },
                { name: 'min_recv', type: 'BigInteger' }
              ]
            )
          ]
        end
        let(:contract_interface) do
          [
            DTRCore::Function.new(
              'multi_swap',
              [
                { name: 'env', type_name: 'Env' },
                { name: 'swap_contract', type_name: 'Address' },
                { name: 'token_a', type_name: 'Address' },
                { name: 'token_b', type_name: 'Address' },
                { name: 'swaps_a', type_name: 'List<SwapSpec>' },
                { name: 'swaps_b', type_name: 'List<SwapSpec>' }
              ],
              nil,
              [
                ins(instruction: 'evaluate', inputs: ['atomic_swap::Client::new', 'env', 'swap_contract'],
                    assign: 'swap_client', scope: 0, id: 7),
                ins(instruction: 'evaluate', inputs: ['swaps_a.iter'], assign: 'ITERATOR_8', scope: 0, id: 12),
                ins(instruction: 'evaluate', inputs: %w[start ITERATOR_8], assign: 'acc_a', scope: 0, id: 13),
                ins(instruction: 'end_of_iteration_check', inputs: %w[acc_a ITERATOR_8],
                    assign: 'CHECK_CONDITION_ASSIGNMENT_9', scope: 0, id: 14),
                ins(instruction: 'jump', inputs: ['CHECK_CONDITION_ASSIGNMENT_9', 15], scope: 0, id: 16),
                ins(instruction: 'evaluate', inputs: ['swaps_b.len'], assign: 'RANGE_END_20', scope: 15, id: 24),
                ins(instruction: 'instantiate_object', inputs: %w[Range 0 RANGE_END_20], assign: 'ITERATOR_17',
                    scope: 15, id: 25),
                ins(instruction: 'evaluate', inputs: %w[start ITERATOR_17], assign: 'i', scope: 15, id: 26),
                ins(instruction: 'end_of_iteration_check', inputs: %w[i ITERATOR_17],
                    assign: 'CHECK_CONDITION_ASSIGNMENT_18', scope: 15, id: 27),
                ins(instruction: 'jump', inputs: ['CHECK_CONDITION_ASSIGNMENT_18', 28], scope: 15, id: 29),
                ins(instruction: 'evaluate', inputs: ['swaps_b.get', 'i'], assign: 'METHOD_CALL_EXPRESSION_30',
                    scope: 28, id: 35),
                ins(instruction: 'evaluate', inputs: ['METHOD_CALL_EXPRESSION_30.unwrap'], assign: 'acc_b', scope: 28,
                    id: 36),
                ins(instruction: 'evaluate', inputs: ['greater_than_or_equal_to', 'acc_a.amount', 'acc_b.min_recv'],
                    assign: 'BINARY_EXPRESSION_LEFT_38', scope: 28, id: 50),
                ins(instruction: 'evaluate', inputs: ['less_than_or_equal_to', 'acc_a.min_recv', 'acc_b.amount'],
                    assign: 'BINARY_EXPRESSION_RIGHT_39', scope: 28, id: 61),
                ins(instruction: 'and', inputs: %w[BINARY_EXPRESSION_LEFT_38 BINARY_EXPRESSION_RIGHT_39],
                    assign: 'CONDITIONAL_JUMP_ASSIGNMENT_37', scope: 28, id: 62),
                ins(instruction: 'jump', inputs: ['CONDITIONAL_JUMP_ASSIGNMENT_37', 63], scope: 28, id: 64),
                ins(instruction: 'evaluate',
                    inputs: ['swap_client.try_swap', 'acc_a.address', 'acc_b.address', 'token_a', 'token_b', 'acc_a.amount', 'acc_a.min_recv', 'acc_b.amount', 'acc_b.min_recv'], assign: 'METHOD_CALL_EXPRESSION_66', scope: 63, id: 103),
                ins(instruction: 'evaluate', inputs: ['METHOD_CALL_EXPRESSION_66.is_ok'],
                    assign: 'CONDITIONAL_JUMP_ASSIGNMENT_65', scope: 63, id: 104),
                ins(instruction: 'jump', inputs: ['CONDITIONAL_JUMP_ASSIGNMENT_65', 105], scope: 63, id: 106),
                ins(instruction: 'evaluate', inputs: ['swaps_b.remove', 'i'], scope: 105, id: 111),
                ins(instruction: 'break', inputs: [], scope: 105, id: 112),
                ins(instruction: 'jump', inputs: ['63'], scope: 105, id: 113),
                ins(instruction: 'jump', inputs: ['28'], scope: 63, id: 114),
                ins(instruction: 'increment', inputs: %w[i ITERATOR_17], scope: 28, id: 115),
                ins(instruction: 'goto', inputs: ['27'], scope: 28, id: 116),
                ins(instruction: 'increment', inputs: %w[acc_a ITERATOR_8], scope: 15, id: 117),
                ins(instruction: 'goto', inputs: ['14'], scope: 15, id: 118)
              ]
            )
          ]
        end
        let(:contract_helpers) { nil }
        let(:contract_non_translatables) do
          'mod atomic_swap {
  soroban_sdk::contractimport!(
    file = "../atomic_swap/target/wasm32-unknown-unknown/release/soroban_atomic_swap_contract.wasm"
  );
}

'
        end

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
            use soroban_sdk::{contract, contracttype, Address, contractimpl, Env, token, Vec, auth::Context, IntoVal, unwrap::UnwrapOptimized};

            mod atomic_swap {
              soroban_sdk::contractimport!(
            		file = "../atomic_swap/target/wasm32-unknown-unknown/release/soroban_atomic_swap_contract.wasm"
            	);
            }

            #[contracttype]
            #[derive(Clone, Debug, Eq, PartialEq)]
            pub struct SwapSpec {
                pub address: Address,
                pub amount: i128,
                pub min_recv: i128,
            }

            #[contract]
            pub struct AtomicMultiSwapContract;

            #[contractimpl]
            impl AtomicMultiSwapContract {
              pub fn multi_swap(env: Env, swap_contract: Address, token_a: Address, token_b: Address, swaps_a: Vec<SwapSpec>, swaps_b: Vec<SwapSpec>)  {
                  let mut swap_client = atomic_swap::Client::new(env, swap_contract);
                  let mut ITERATOR_8 = swaps_a.iter();
                  let mut OPTION_acc_a = ITERATOR_8.next();
                  while let Some(acc_a) = OPTION_acc_a {
                    let mut RANGE_END_20 = swaps_b.len();
                    let mut ITERATOR_17 = 0..RANGE_END_20;
                    let mut OPTION_i = ITERATOR_17.next();
                    while let Some(i) = OPTION_i {
                      let mut METHOD_CALL_EXPRESSION_30 = swaps_b.get(i);
                      let mut acc_b = METHOD_CALL_EXPRESSION_30.unwrap();
                      let BINARY_EXPRESSION_LEFT_38 = acc_a.amount >= acc_b.min_recv;
                      let BINARY_EXPRESSION_RIGHT_39 = acc_a.min_recv <= acc_b.amount;
                      let CONDITIONAL_JUMP_ASSIGNMENT_37 = BINARY_EXPRESSION_LEFT_38 && BINARY_EXPRESSION_RIGHT_39;
                      if CONDITIONAL_JUMP_ASSIGNMENT_37 {
                        let mut METHOD_CALL_EXPRESSION_66 = swap_client.try_swap(acc_a.address, acc_b.address, token_a, token_b, acc_a.amount, acc_a.min_recv, acc_b.amount, acc_b.min_recv);
                        let mut CONDITIONAL_JUMP_ASSIGNMENT_65 = METHOD_CALL_EXPRESSION_66.is_ok();
                        if CONDITIONAL_JUMP_ASSIGNMENT_65 {
                          swaps_b.remove(i);
                          break;
                        }
                      }
                      OPTION_i = ITERATOR_17.next();
                    }
                  OPTION_acc_a = ITERATOR_8.next();
                }
              }
            }
          RUST
        end

        it 'generates the correct contract' do
          puts "\nActual"
          puts described_class.generate(contract)
          puts "\n"

          expect(described_class.generate(contract).gsub("\t", '').gsub(' ',
                                                                        '').gsub("\n", '')).to eq(expected_output.gsub("\t", '').gsub(
                                                                          ' ', ''
                                                                        ).gsub("\n", ''))
        end
      end
    end
  end
end
