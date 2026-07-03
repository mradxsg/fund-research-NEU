import { AppSpacing } from '../../common/constants/AppConstants'
import { TagChip } from './TagChip'

@Preview
@Component
export struct TagBar {
  @Prop items: string[] = []
  @Prop selectedIndex: number = -1
  @Prop mode: string = 'fill'
  onSelect: (index: number) => void = (_index: number): void => {}

  build() {
    Row({ space: AppSpacing.SM }) {
      ForEach(this.items, (item: string, i: number) => {
        TagChip({
          label: item,
          selected: i === this.selectedIndex,
          mode: this.mode,
          onChipClick: (): void => {
            if (i === this.selectedIndex) {
              this.onSelect(-1)
            } else {
              this.onSelect(i)
            }
          }
        })
      }, (item: string, i: number) => i.toString())
    }
    .width('100%')
    .padding({ left: AppSpacing.LG, right: AppSpacing.LG })
  }
}