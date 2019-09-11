module ToursHelper
  def create_item_tour_data_step(index)
    steps = [
      {
        'id' => 'create-item-tour',
        'step' => 1,
        'intro' => "#{t('tours.item.intro')}",
        'position' => 'right',
        'disable-interaction' => true,
        'done-label' => t('tours.next')
      },
      {
        'id' => 'create-item-tour',
        'step' => 2,
        'intro' => "#{t('tours.item.intro')}",
        'position' => 'left',
        'disable-interaction' => true,
        'done-label' => t('tours.next')
      },
      {
        'id' => 'create-item-tour',
        'step' => 3,
        'intro' => "#{t('tours.item.intro')}",
        'position' => 'left',
        'disable-interaction' => true,
        'done-label' => t('tours.next')
      },
      {
        'id' => 'create-item-tour',
        'step' => 4,
        'intro' => "#{t('tours.item.intro')}",
        'position' => 'left',
        'disable-interaction' => true,
        'done-label' => t('tours.next')
      },
      {
        'id' => 'create-item-tour',
        'step' => 5,
        'intro' => "#{t('tours.item.intro')}",
        'position' => 'left',
        'disable-interaction' => true,
        'done-label' => t('tours.next')
      },
      {
        'id' => 'create-item-tour',
        'step' => 6,
        'intro' => "#{t('tours.item.intro')}",
        'position' => 'left',
        'disable-interaction' => true,
        'done-label' => t('tours.next')
      },
      {
        'id' => 'create-item-tour',
        'step' => 7,
        'intro' => "#{t('tours.item.intro')}",
        'position' => 'left',
        'disable-interaction' => true,
        'done-label' => t('tours.next')
      }

    ]
    steps[index - 1]
  end
end
