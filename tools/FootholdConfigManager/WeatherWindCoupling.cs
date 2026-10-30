namespace FootholdConfigManager;

internal static class WeatherWindCoupling
{
    // Installed DCS Weather helper: ground normalization plus the static profile's
    // 500 m interpolation. The helper rounds its result to whole m/s with lrint.
    private static readonly double GroundTo500Factor = Math.Pow(45, .2) * (1 - Math.Exp(-Math.Pow(1.5, 4)));
    private static readonly double Level500ToGroundFactor = Math.Pow(11d / 500,
        (1.379e-6 * 11 * 11 - 3.592e-10 * 11 * 11 * 11 - .001844 * 11 + .9957) * .2);

    internal static double GroundTo500(double speedMps) => Math.Round(speedMps * GroundTo500Factor, MidpointRounding.ToEven);
    internal static double Level500ToGround(double speedMps) => Math.Round(speedMps * Level500ToGroundFactor, MidpointRounding.ToEven);
}
