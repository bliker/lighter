describe 'Various parsing helepers', ->

    describe 'can_be_nested', ->

        it 'with undefined', ->
            result = markdown.can_be_nested(undefined)
            expect(result).toBe(false)

        it 'with ol/ul', ->
            result = markdown.can_be_nested(type: 'ol')
            expect(result).toBe(true)

            result = markdown.can_be_nested(type: 'ul')
            expect(result).toBe(true)

        it 'with random stuff', ->
            result = markdown.can_be_nested(type: 'h3')
            expect(result).toBe(false)

    describe 'is_whitespace', ->

        it 'with undefined', ->
            result = markdown.is_whitespace(undefined)
            expect(result).toBe(false)

        it 'with some character', ->
            result = markdown.is_whitespace('s')
            expect(result).toBe(false)

        it 'with some commom whitespace', ->
            result = markdown.is_whitespace(' ')
            expect(result).toBe(true)

            result = markdown.is_whitespace('\t')
            expect(result).toBe(true)