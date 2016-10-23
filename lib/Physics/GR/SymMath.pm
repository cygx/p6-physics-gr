unit package Physics::GR;

class Term is export {
    has Numeric $.prefactor;
    has Mix $.powers;

    method Str {
        my $pre = do given $!prefactor {
            when 1 { '' }
            when -1 { '-' }
            when Real { "$_ " }
            default { "($_) " }
        }
        $pre ~ join ' ', $!powers.keys.sort.map: {
            $_ ~ ($_ == 1 ?? '' !! "^$_" given $!powers{$_});
        }
    }

    method negate { Term.new(:prefactor(-$!prefactor), :$!powers) }
    method invert {
        Term.new(
            prefactor => 1/$!prefactor,
            powers => $!powers.pairs.map({ .key => -.value }).Mix
        );
    }
}

role SymMath is export {
    method term(Numeric $prefactor = 1, *%_) {
        Term.new(:$prefactor, :powers(%_.map({ .key => +.value }).Mix));
    }
}
