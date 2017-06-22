use Physics::GR::Categories;

package Physics::GR {
    class Func { ... }
    class DFunc { ... }
    class Term { ... }

    class Term does Symbolic {
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
                ($_ ~~ Str ?? "$_" !! "($_)") ~
                ($_ == 1 ?? '' !! "^$_" given $!powers{$_});
            }
        }

        method NEG { Term.new(:prefactor(-$!prefactor), :$!powers) }
        method INV {
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
        multi method MUL($a: Term $b) {
            Term.new(
                prefactor => $a.prefactor * $b.prefactor,
                powers => $a.powers (+) $b.powers
            );
        }
    }

    class Func does Symbolic {
        has Str $.name;
        has List $.parameters;
        method Str { "$!name\({$!parameters.join(',')})" }
        method diff {
            return 0 if none(|%_.keys) eq any(|$!parameters);
            my $differentials = %_.Bag;
            DFunc.new(:$!name, :$!parameters, :$differentials);
        }
        multi method MUL(Numeric $x) {
            Term.new(:prefactor($x), :powers(((self) => 1).Mix));
        }
    }

    class DFunc is Func {
        has Bag $.differentials;
        method order { $!differentials.total }
        method Str {
            my $n := $.order;
            "d{$n == 1 ?? '' !! "^$n "}{callsame} / $_"
                given join ' ', $!differentials.keys.sort.map: {
                    my $k := $!differentials{$_};
                    "d$_" ~ ($k == 1 ?? '' !! "^$k");
                }
        }
        method diff {
            return 0 if none(|%_.keys) eq any(|$.parameters);
            my $differentials = $!differentials (+) %_.Bag;
            DFunc.new(:$.name, :$.parameters, :$differentials);
        }
    }

    role SymMath {
        method term(Numeric $prefactor = 1, *%_) {
            Term.new(:$prefactor, :powers(%_.map({ .key => +.value }).Mix));
        }
        method func(Str $name, *@parameters) {
            Func.new(:$name, :@parameters);
        }
    }
}

sub EXPORT {
    BEGIN Map.new((
        Term => Physics::GR::Term,
        Func => Physics::GR::Func,
        DFunc => Physics::GR::DFunc,
    ));
}
