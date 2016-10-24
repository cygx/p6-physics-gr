unit package Physics::GR;
use Physics::GR::Symbolic;

class Term does Symbolic is export {
    has Numeric $.prefactor;
    has Mix $.powers;

    method new {
        self.bless(|%_) does Symbolic; # Bug!
    }

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

    multi method MUL(0) { 0 }
    multi method MUL(NaN) { NaN }
    multi method MUL(Numeric $x) {
        Term.new(:prefactor($x * $!prefactor), :$!powers);
    }
}

role SymMath is export {
    method term(Numeric $prefactor = 1, *%_) {
        Term.new(:$prefactor, :powers(%_.map({ .key => +.value }).Mix));
    }
}
