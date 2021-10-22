# TODO: criar propostas com status diferentes
proposal_1 = Proposal.create!({
  message: 'John\'s proposal on project 1',
  value_per_hour: 80.80,
  hours_per_week: 20,
  finish_date: Time.current + 3.day,
  status: :pending,
  project_id: 1,
  professional_id: 1,
  # approved_at: Time.current,
  # cancel_reason: 'Rerum sed ipsam qui delectus ut excepturi fugit'
})

proposal_2 = Proposal.create!({
  message: 'Schneider\'s proposal on project 1',
  value_per_hour: 99.99,
  hours_per_week: 30,
  finish_date: Time.current + 1.week,
  status: :pending,
  project_id: 1,
  professional_id: 2,
  # approved_at: Time.current,
  # cancel_reason: 'Rerum sed ipsam qui delectus ut excepturi fugit'
})

proposal_3 = Proposal.create!({
  message: 'John\'s proposal on project 2',
  value_per_hour: 11,
  hours_per_week: 10,
  finish_date: Time.current + 3.day,
  status: :pending,
  project_id: 2,
  professional_id: 1,
  # approved_at: Time.current,
  # cancel_reason: 'Rerum sed ipsam qui delectus ut excepturi fugit'
})
