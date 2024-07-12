# frozen_string_literal: true

require 'spec_helper'

RSpec.describe SorobanRustBackend::LCPBT_Forrest do
  ### Forrest structure
  ###
  ###
  context 'when no trees in forrest' do
    it 'is sane and traverses self' do
      forrest = described_class.new
      expect(forrest.trees).to eq([])
      expect(forrest.traverse).to eq([])
    end
  end

  ### Forrest structure
  ###
  #       -------------
  #       |      1    |
  #       |     / \   |
  #       |    2   3  |
  #       |   / \     |
  #       |  4   5    |
  #       -------------
  ###
  context 'when one tree in forrest' do
    it 'traverses tree' do
      forrest = described_class.new
      tree = SorobanRustBackend::LeftChildPreferentialBinaryTree.new(1)
      node2 = SorobanRustBackend::LeftChildPreferentialBinaryTree.new(2)
      node3 = SorobanRustBackend::LeftChildPreferentialBinaryTree.new(3)
      node4 = SorobanRustBackend::LeftChildPreferentialBinaryTree.new(4)
      node5 = SorobanRustBackend::LeftChildPreferentialBinaryTree.new(5)
      tree.set_left_child(node2)
      tree.set_right_child(node3)
      node2.set_left_child(node4)
      node2.set_right_child(node5)
      forrest.add_tree(tree)
      expect(forrest.trees).to eq([tree])
      expect(forrest.traverse.flatten).to eq([1, 2, 4, 5, 3])
    end
  end

  ### Forrest structure
  ###
  #       -------------
  #       |      1    |
  #       |     / \   |
  #       |    2   3  |
  #       |   / \     |
  #       |  4   5    |
  #       -------------
  #
  #       -------------
  #       |      6    |
  #       |     / \   |
  #       |    7   8  |
  #       -------------
  #
  #       -------------
  #       |      9    |
  #       |     /     |
  #       |    10     |
  #       -------------
  ###
  context 'when multiple trees in forrest' do
    it 'traverses all trees' do
      forrest = described_class.new
      tree1 = SorobanRustBackend::LeftChildPreferentialBinaryTree.new(1)
      node2 = SorobanRustBackend::LeftChildPreferentialBinaryTree.new(2)
      node3 = SorobanRustBackend::LeftChildPreferentialBinaryTree.new(3)
      node4 = SorobanRustBackend::LeftChildPreferentialBinaryTree.new(4)
      node5 = SorobanRustBackend::LeftChildPreferentialBinaryTree.new(5)
      tree1.set_left_child(node2)
      tree1.set_right_child(node3)
      node2.set_left_child(node4)
      node2.set_right_child(node5)
      tree2 = SorobanRustBackend::LeftChildPreferentialBinaryTree.new(6)
      node7 = SorobanRustBackend::LeftChildPreferentialBinaryTree.new(7)
      node8 = SorobanRustBackend::LeftChildPreferentialBinaryTree.new(8)
      tree2.set_left_child(node7)
      tree2.set_right_child(node8)
      tree3 = SorobanRustBackend::LeftChildPreferentialBinaryTree.new(9)
      node10 = SorobanRustBackend::LeftChildPreferentialBinaryTree.new(10)
      tree3.set_left_child(node10)
      forrest.add_tree(tree1)
      forrest.add_tree(tree2)
      forrest.add_tree(tree3)
      expect(forrest.trees).to eq([tree1, tree2, tree3])
      expect(forrest.traverse.flatten).to eq([1, 2, 4, 5, 3, 6, 7, 8, 9, 10])
    end
  end
end
