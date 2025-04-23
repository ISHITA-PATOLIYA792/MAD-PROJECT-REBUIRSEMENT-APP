// Follow this setup guide to integrate the Deno runtime into your application:
// https://deno.land/manual/examples/deploy_supabase_function

import { serve } from 'https://deno.land/std@0.177.0/http/server.ts'
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

interface ExpenseSubmissionRequest {
  type: 'submission'
  expenseId: string
  employeeId: string
  managerId: string
  expenseDetails: {
    title: string
    amount: number
    currency: string
    date: string
    category: string
    project: string
    description?: string
    tracking_id: string
    receipt_url?: string
  }
}

interface ExpenseStatusUpdateRequest {
  type: 'status_update'
  expenseId: string
  employeeId: string
  status: string
  approverName: string
  rejectionReason?: string
}

type RequestBody = ExpenseSubmissionRequest | ExpenseStatusUpdateRequest

serve(async (req) => {
  // handle CORS preflight
  if (req.method === 'OPTIONS') {
    return new Response(null, {
      status: 204,
      headers: {
        'Access-Control-Allow-Origin': '*',
        'Access-Control-Allow-Methods': 'POST, OPTIONS',
        'Access-Control-Allow-Headers': 'Content-Type',
      },
    });
  }

  try {
    // Create Supabase client with Admin key
    const supabaseClient = createClient(
      Deno.env.get('SUPABASE_URL') ?? '',
      Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? ''
    )

    // Parse request body
    const requestData: RequestBody = await req.json()

    if (requestData.type === 'submission') {
      // Handle expense submission notification
      await handleExpenseSubmissionEmail(requestData, supabaseClient)
    } else if (requestData.type === 'status_update') {
      // Handle expense status update notification
      await handleExpenseStatusUpdateEmail(requestData, supabaseClient)
    } else {
      throw new Error('Invalid notification type')
    }

    return new Response(
      JSON.stringify({ success: true }),
      {
        status: 200,
        headers: {
          'Content-Type': 'application/json',
          'Access-Control-Allow-Origin': '*',
        },
      },
    )
  } catch (error) {
    return new Response(
      JSON.stringify({ error: error.message }),
      {
        status: 400,
        headers: {
          'Content-Type': 'application/json',
          'Access-Control-Allow-Origin': '*',
        },
      },
    )
  }
})

async function handleExpenseSubmissionEmail(
  data: ExpenseSubmissionRequest,
  supabaseClient: any
) {
  // Get employee data
  const { data: employee } = await supabaseClient
    .from('profiles')
    .select('name, email')
    .eq('id', data.employeeId)
    .single()

  // Get manager data
  const { data: manager } = await supabaseClient
    .from('profiles')
    .select('name, email')
    .eq('id', data.managerId)
    .single()

  if (!employee || !manager) {
    throw new Error('Employee or manager not found')
  }

  // Format date
  const expenseDate = new Date(data.expenseDetails.date)
  const formattedDate = expenseDate.toLocaleDateString('en-US', {
    year: 'numeric',
    month: 'long',
    day: 'numeric',
  })

  // Generate secure approval/rejection tokens
  const approveToken = crypto.randomUUID()
  const rejectToken = crypto.randomUUID()

  // Store tokens in database
  await supabaseClient.from('approval_tokens').insert([
    {
      token: approveToken,
      tracking_id: data.expenseDetails.tracking_id,
      reviewer_id: data.managerId,
      action: 'approve',
      expires_at: new Date(Date.now() + 7 * 24 * 60 * 60 * 1000).toISOString(), // 7 days expiry
    },
    {
      token: rejectToken,
      tracking_id: data.expenseDetails.tracking_id,
      reviewer_id: data.managerId,
      action: 'reject',
      expires_at: new Date(Date.now() + 7 * 24 * 60 * 60 * 1000).toISOString(), // 7 days expiry
    },
  ])

  // Generate approval/rejection URLs
  const baseUrl = Deno.env.get('APP_URL') || 'https://example.com'
  const approveUrl = `${baseUrl}/api/expense-action?action=approve&expense_id=${data.expenseId}&tracking_id=${data.expenseDetails.tracking_id}&token=${approveToken}`
  const rejectUrl = `${baseUrl}/api/expense-action?action=reject&expense_id=${data.expenseId}&tracking_id=${data.expenseDetails.tracking_id}&token=${rejectToken}`

  // Generate email content
  const emailSubject = `Expense Approval Required: ${data.expenseDetails.title} (${data.expenseDetails.tracking_id})`

  const emailHtml = `
    <h2>Expense Approval Required</h2>
    <p>Hello ${manager.name},</p>
    <p>An expense has been submitted that requires your approval:</p>
    
    <div style="margin: 20px 0; padding: 15px; border: 1px solid #ddd; border-radius: 5px;">
      <h3 style="margin-top: 0;">${data.expenseDetails.title}</h3>
      <p><strong>Tracking ID:</strong> ${data.expenseDetails.tracking_id}</p>
      <p><strong>Amount:</strong> ${data.expenseDetails.currency} ${data.expenseDetails.amount.toFixed(2)}</p>
      <p><strong>Category:</strong> ${data.expenseDetails.category}</p>
      <p><strong>Project:</strong> ${data.expenseDetails.project}</p>
      <p><strong>Date:</strong> ${formattedDate}</p>
      <p><strong>Submitted By:</strong> ${employee.name} (${employee.email})</p>
      ${data.expenseDetails.description ? `<p><strong>Description:</strong> ${data.expenseDetails.description}</p>` : ''}
      
      ${data.expenseDetails.receipt_url ? `
        <div style="margin-top: 15px;">
          <p><strong>Receipt:</strong></p>
          <img src="${data.expenseDetails.receipt_url}" alt="Receipt" style="max-width: 300px; max-height: 200px;" />
        </div>
      ` : ''}
    </div>
    
    <div style="margin: 25px 0;">
      <a href="${approveUrl}" style="display: inline-block; padding: 10px 20px; margin-right: 10px; background-color: #4CAF50; color: white; text-decoration: none; border-radius: 4px;">Approve</a>
      <a href="${rejectUrl}" style="display: inline-block; padding: 10px 20px; background-color: #f44336; color: white; text-decoration: none; border-radius: 4px;">Reject</a>
    </div>
    
    <p>You can also review this expense in detail by logging into the expense management system.</p>
    
    <p>Thank you,<br>Reimbursement Box Team</p>
  `

  // Send email (in a real app, this would use a proper email service)
  console.log(`[MOCK EMAIL] To: ${manager.email}, Subject: ${emailSubject}`)
  console.log(`[MOCK EMAIL] Content: ${emailHtml}`)

  // In a real implementation, we would use a service like SendGrid, Mailgun, etc.
  // For example with SendGrid:
  /*
  await fetch('https://api.sendgrid.com/v3/mail/send', {
    method: 'POST',
    headers: {
      'Authorization': `Bearer ${Deno.env.get('SENDGRID_API_KEY')}`,
      'Content-Type': 'application/json'
    },
    body: JSON.stringify({
      personalizations: [{ to: [{ email: manager.email }] }],
      from: { email: 'noreply@reimbursementbox.com', name: 'Reimbursement Box' },
      subject: emailSubject,
      content: [{ type: 'text/html', value: emailHtml }]
    })
  })
  */
}

async function handleExpenseStatusUpdateEmail(
  data: ExpenseStatusUpdateRequest,
  supabaseClient: any
) {
  // Get employee data
  const { data: employee } = await supabaseClient
    .from('profiles')
    .select('name, email')
    .eq('id', data.employeeId)
    .single()

  if (!employee) {
    throw new Error('Employee not found')
  }

  // Get expense details
  const { data: expense } = await supabaseClient
    .from('expenses')
    .select('title, tracking_id, amount, currency, date, project, category')
    .eq('id', data.expenseId)
    .single()

  if (!expense) {
    throw new Error('Expense not found')
  }

  // Format date
  const expenseDate = new Date(expense.date)
  const formattedDate = expenseDate.toLocaleDateString('en-US', {
    year: 'numeric',
    month: 'long',
    day: 'numeric',
  })

  // Generate email content
  const statusText = data.status === 'approved' ? 'Approved' : 'Rejected'
  const emailSubject = `Expense ${statusText}: ${expense.title} (${expense.tracking_id})`

  const emailHtml = `
    <h2>Expense ${statusText}</h2>
    <p>Hello ${employee.name},</p>
    
    <p>Your expense <strong>${expense.title}</strong> (${expense.tracking_id}) has been <strong>${data.status}</strong> by ${data.approverName}.</p>
    
    <div style="margin: 20px 0; padding: 15px; border: 1px solid #ddd; border-radius: 5px; background-color: ${data.status === 'approved' ? '#f1f8e9' : '#ffebee'}">
      <h3 style="margin-top: 0;">${expense.title}</h3>
      <p><strong>Tracking ID:</strong> ${expense.tracking_id}</p>
      <p><strong>Amount:</strong> ${expense.currency} ${expense.amount.toFixed(2)}</p>
      <p><strong>Category:</strong> ${expense.category}</p>
      <p><strong>Project:</strong> ${expense.project}</p>
      <p><strong>Date:</strong> ${formattedDate}</p>
      <p><strong>Status:</strong> <span style="color: ${data.status === 'approved' ? 'green' : 'red'}; font-weight: bold;">${statusText}</span></p>
      
      ${data.status === 'rejected' && data.rejectionReason ? `
        <div style="margin-top: 15px; padding: 10px; background-color: #ffebee; border-left: 4px solid #f44336;">
          <p><strong>Reason for Rejection:</strong></p>
          <p>${data.rejectionReason}</p>
        </div>
      ` : ''}
    </div>
    
    <p>You can view the details of this expense in the Reimbursement Box app.</p>
    
    <p>Thank you,<br>Reimbursement Box Team</p>
  `

  // Send email (in a real app, this would use a proper email service)
  console.log(`[MOCK EMAIL] To: ${employee.email}, Subject: ${emailSubject}`)
  console.log(`[MOCK EMAIL] Content: ${emailHtml}`)

  // In a real implementation, we would use a service like SendGrid, Mailgun, etc.
} 