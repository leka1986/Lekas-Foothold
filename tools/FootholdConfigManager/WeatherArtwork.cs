using System.Drawing.Drawing2D;

namespace FootholdConfigManager;

internal static class WeatherArtwork
{
    internal static void Draw(Graphics graphics, Rectangle bounds, Color color)
    {
        var state = graphics.Save();
        graphics.SmoothingMode = SmoothingMode.AntiAlias;
        graphics.TranslateTransform(bounds.X, bounds.Y);
        graphics.ScaleTransform(bounds.Width / 24f, bounds.Height / 24f);
        using var pen = new Pen(color, 1.5f) { StartCap = LineCap.Round, EndCap = LineCap.Round, LineJoin = LineJoin.Round };
        graphics.DrawArc(pen, 9, 4, 10, 10, 185, 235);
        graphics.DrawLine(pen, 14, 0, 14, 2);
        graphics.DrawLine(pen, 21, 3, 20, 4);
        graphics.DrawLine(pen, 22, 9, 24, 9);
        graphics.DrawLine(pen, 7, 2, 8, 3);
        using var cloud = new GraphicsPath();
        cloud.AddBezier(6, 21, 0, 21, 0, 12, 6, 12);
        cloud.AddBezier(6, 12, 7, 5, 17, 8, 16, 14);
        cloud.AddBezier(16, 14, 23, 13, 23, 21, 17, 21);
        cloud.CloseFigure();
        graphics.DrawPath(pen, cloud);
        graphics.Restore(state);
    }
}