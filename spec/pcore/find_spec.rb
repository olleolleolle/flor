
#
# specifying flor
#
# Sun Nov 12 14:03:32 JST 2017
#

require 'spec_helper'


describe 'Flor procedures' do

  before :each do

    @executor = Flor::TransientExecutor.new
  end

  describe 'find' do

    it 'finds the first matching array element' do

      r = @executor.launch(
        %q{
          find [ 1, 2, 3 ]
            def elt
              (elt % 2) == 0
        })

      expect(r['point']).to eq('terminated')
      expect(r['payload']['ret']).to eq(2)
    end

    it 'finds the first matching object entry' do

      r = @executor.launch(
        %q{
          find { a: 'A', b: 'B', c: 'C' }
            def key, val
              val == 'B'
        })

      expect(r['point']).to eq('terminated')
      expect(r['payload']['ret']).to eq(%w[ b B ])
    end

    it 'returns null when it does not find in an array' do

      r = @executor.launch(
        %q{
          find [ 1, 2, 3 ]
            def elt \ elt == 4
        })

      expect(r['point']).to eq('terminated')
      expect(r['payload']['ret']).to eq(nil)
    end

    it 'returns null when it does not find in an object' do

      r = @executor.launch(
        %q{
          find { a: 'A', b: 'B', c: 'C' }
            def key, val
              val == 'Z'
        })

      expect(r['point']).to eq('terminated')
      expect(r['payload']['ret']).to eq(nil)
    end
  end
end

