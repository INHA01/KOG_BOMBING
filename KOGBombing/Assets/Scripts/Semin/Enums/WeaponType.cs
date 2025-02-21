using System.Collections.Generic;

public enum WeaponType
{
    GUN,
    MOLOTOV,
    LANDMINE,
    BOMB,
    SHOCK_GRENADE,
    NONE,
    MAX
}

public class WeaponComparer : IEqualityComparer<WeaponType>
{
    bool IEqualityComparer<WeaponType>.Equals(WeaponType x, WeaponType y)
    {
        return x == y;
    }

    int IEqualityComparer<WeaponType>.GetHashCode(WeaponType obj)
    {
        return (int)obj;
    }
}