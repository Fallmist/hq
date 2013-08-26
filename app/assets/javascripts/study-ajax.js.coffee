$ ->
  updateSpecialities = (faculty_id) ->
    $.getJSON 'ajax/specialities', {
      'faculty': faculty_id
    }, (specialities) ->
      select = $('.ajax-speciality')[0]
      if select
        select.options.length = 0
        select.options.add(
          new Option("#{speciality.code} #{speciality.name}", speciality.id)
        ) for speciality in specialities
        $(select).val(specialities[0].id).change()

  updateGroups = (speciality_id) ->
    $.getJSON 'ajax/groups', {
      'speciality': speciality_id
    }, (groups) ->
      select = $('.ajax-group')[0]
      if select
        select.options.length = 0
        select.options.add(
          new Option(group.name, group.id)
        ) for group in groups
        $(select).val(groups[0].id).change()

  $('.ajax-faculty').change ->
    updateSpecialities($(this).val())
  $('.ajax-speciality').change ->
    updateGroups($(this).val())

  $('.ajax-faculty').change()