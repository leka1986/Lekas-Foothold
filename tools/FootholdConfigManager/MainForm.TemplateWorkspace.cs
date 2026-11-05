using System.Drawing;
using System.Windows.Forms;

namespace FootholdConfigManager;

internal sealed partial class MainForm
{
    private void ConfigureTableHeaderSizing(TableLayoutPanel group, FlowLayoutPanel header, Font? headingFont = null)
    {
        if (group.RowStyles.Count == 0) group.RowStyles.Add(new RowStyle(SizeType.AutoSize));
        group.RowStyles[0].SizeType = SizeType.Absolute;
        header.Dock = DockStyle.Fill;
        header.AutoSize = false;
        header.WrapContents = true;
        var heading = header.Controls.OfType<Label>().First();
        heading.Font = headingFont ?? GetConfigValueFont(2.85f, FontStyle.Bold);
        void SizeHeaderRow()
        {
            if (!ReferenceEquals(header.Parent, group)) return;
            var height = header.GetPreferredSize(new Size(header.ClientSize.Width, 0)).Height +
                header.Margin.Vertical;
            if (Math.Abs(group.RowStyles[0].Height - height) >= 1)
            {
                group.RowStyles[0].Height = height;
                EditorSection.RunLayoutPass(group.PerformLayout);
                if (group.IsHandleCreated)
                    group.BeginInvoke((Action)(() => { if (!group.IsDisposed && group.FindForm() is not null) EditorSection.RunLayoutPass(group.PerformLayout); }));
            }
        }
        SizeHeaderRow();
        group.HandleCreated += (_, _) => group.BeginInvoke((Action)(() =>
        {
            if (!group.IsDisposed && group.FindForm() is not null) EditorSection.RunLayoutPass(group.PerformLayout);
        }));
        void SizeHeading()
        {
            var width = Math.Max(180, header.ClientSize.Width - header.Padding.Horizontal - heading.Margin.Horizontal);
            if (heading.MaximumSize.Width == width) return;
            heading.MaximumSize = new Size(width, 0);
            SizeHeaderRow();
        }
        header.SizeChanged += (_, _) => SizeHeading();
        void WireHeaderChild(Control child)
        {
            child.SizeChanged += (_, _) => SizeHeaderRow();
            child.VisibleChanged += (_, _) => SizeHeaderRow();
        }
        foreach (Control child in header.Controls) WireHeaderChild(child);
        header.ControlAdded += (_, args) =>
        {
            WireHeaderChild(args.Control!);
            SizeHeaderRow();
        };
        SizeHeading();
    }

    private void PrepareTemplateEditor(Control editor, DesignerItem item)
    {
        ApplyTemplateAppearance(editor, item);
        if (editor is TableLayoutPanel group && group.Tag is TableEditorBinding binding)
        {
            group.SetColumnSpan(binding.Header, group.ColumnCount);
        }
    }
}
