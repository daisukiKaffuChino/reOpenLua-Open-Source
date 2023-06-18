package com.open.lua.widget;

import android.content.*;
import android.graphics.*;
import android.view.*;
import com.androlua.*;
import com.luajava.*;


/*
 if (mTable != null)
 {
 String NOW_METHOD_NAME = Thread.currentThread() .getStackTrace()[2].getMethodName();
 try
 {
 LuaObject mTableValue = mTable.getField(NOW_METHOD_NAME);
 if (!mTableValue.isNil())
 {
 if (mTableValue.isFunction())
 {
 LuaFunction mFunction = mTableValue.getFunction();
 //需要传入的参数
 mFunction.call(canvas, this);
 }
 else
 {
 throw new LuaException("\n" + NOW_METHOD_NAME + "不是一个function");
 }
 }
 }
 catch (Exception e)
 {
 mContext.sendError(this.getClass() + "的" + NOW_METHOD_NAME + "方法异常", e);
 }
 }

 */



//让Lua可以继承View,并重写一些方法
public class LuaView extends View
{
	private LuaContext mContext;
    private LuaTable mTable;

    public LuaView(Context context)
	{
        this(context, null);
    }
	
    public LuaView(Context context, LuaTable table)
	{
		super(context);
		mContext = (LuaContext) context;
        mTable = table;
		
		//默认点击事件
		this.setOnClickListener(new OnClickListener(){
				@Override
				public void onClick(View v)
				{
					if (mTable != null)
					{
						String NOW_METHOD_NAME = Thread.currentThread() .getStackTrace()[2].getMethodName();
						try
						{
							LuaObject mTableValue = mTable.getField(NOW_METHOD_NAME);
							if (!mTableValue.isNil())
							{
								if (mTableValue.isFunction())
								{
									LuaFunction mFunction = mTableValue.getFunction();
									//需要传入的参数
									mFunction.call(v, this);
								}
								else
								{
									throw new LuaException("\n" + NOW_METHOD_NAME + "不是一个function");
								}
							}
						}
						catch (Exception e)
						{
							mContext.sendError(this.getClass() + "的" + NOW_METHOD_NAME + "方法异常", e);
						}
					}
				}
			});
		//默认长按事件
		this.setOnLongClickListener(new OnLongClickListener(){
			    @Override
				public boolean onLongClick(View v)
				{
					if (mTable != null)
					{
						String NOW_METHOD_NAME = Thread.currentThread() .getStackTrace()[2].getMethodName();
						try
						{
							LuaObject mTableValue = mTable.getField(NOW_METHOD_NAME);
							if (!mTableValue.isNil())
							{
								if (mTableValue.isFunction())
								{
									LuaFunction mFunction = mTableValue.getFunction();
									//需要传入的参数
									mFunction.call(v, this);
								}
								else
								{
									throw new LuaException("\n" + NOW_METHOD_NAME + "不是一个function");
								}
							}
						}
						catch (Exception e)
						{
							mContext.sendError(this.getClass() + "的" + NOW_METHOD_NAME + "方法异常", e);
						}
					}
					return true;
				}
			});


    }
	
	
	
	
	
	


    @Override
    protected void onMeasure(int w, int h)
	{
		super.onMeasure(w, h);
        if (mTable != null)
		{
			String NOW_METHOD_NAME = Thread.currentThread() .getStackTrace()[2].getMethodName();
			try
			{
				LuaObject mTableValue = mTable.getField(NOW_METHOD_NAME);
				if (!mTableValue.isNil())
				{
					if (mTableValue.isFunction())
					{
						LuaFunction mFunction = mTableValue.getFunction();
						//需要传入的参数
						mFunction.call(w, h, this);
					}
					else
					{
						throw new LuaException("\n" + NOW_METHOD_NAME + "不是一个function");
					}
				}
			}
			catch (Exception e)
			{
				mContext.sendError(this.getClass() + "的" + NOW_METHOD_NAME + "方法异常", e);
			}
		}
    }



	@Override
	protected void onSizeChanged(int w, int h, int oldw, int oldh)
	{
		// TODO: Implement this method
		super.onSizeChanged(w, h, oldw, oldh);
		
		if (mTable != null)
		{
			String NOW_METHOD_NAME = Thread.currentThread() .getStackTrace()[2].getMethodName();
			try
			{
				LuaObject mTableValue = mTable.getField(NOW_METHOD_NAME);
				if (!mTableValue.isNil())
				{
					if (mTableValue.isFunction())
					{
						LuaFunction mFunction = mTableValue.getFunction();
						//需要传入的参数
						mFunction.call(w,h,this);
					}
					else
					{
						throw new LuaException("\n" + NOW_METHOD_NAME + "不是一个function");
					}
				}
			}
			catch (Exception e)
			{
				mContext.sendError(this.getClass() + "的" + NOW_METHOD_NAME + "方法异常", e);
			}
		}
		
		
		if (mTable != null)
		{
			String NOW_METHOD_NAME = Thread.currentThread() .getStackTrace()[2].getMethodName();
			try
			{
				LuaObject mTableValue = mTable.getField(NOW_METHOD_NAME);
				if (!mTableValue.isNil())
				{
					if (mTableValue.isFunction())
					{
						LuaFunction mFunction = mTableValue.getFunction();
						//需要传入的参数
						mFunction.call(w, h, oldw, oldh, this);
					}
					else
					{
						throw new LuaException("\n" + NOW_METHOD_NAME + "不是一个function");
					}
				}
			}
			catch (Exception e)
			{
				mContext.sendError(this.getClass() + "的" + NOW_METHOD_NAME + "方法异常", e);
			}
		}
		
		


	}

	@Override
	protected void onDraw(Canvas canvas)
	{
		super.onDraw(canvas);

		if (mTable != null)
		{
			String NOW_METHOD_NAME = Thread.currentThread() .getStackTrace()[2].getMethodName();
			try
			{
				LuaObject mTableValue = mTable.getField(NOW_METHOD_NAME);
				if (!mTableValue.isNil())
				{
					if (mTableValue.isFunction())
					{
						LuaFunction mFunction = mTableValue.getFunction();
						//需要传入的参数
						mFunction.call(canvas, this);
					}
					else
					{
						throw new LuaException("\n" + NOW_METHOD_NAME + "不是一个function");
					}
				}
			}
			catch (Exception e)
			{
				mContext.sendError(this.getClass() + "的" + NOW_METHOD_NAME + "方法异常", e);
			}
		}

    }


	@Override
	protected void onLayout(boolean changed, int left, int top, int right, int bottom)
	{
		super.onLayout(changed, left, top, right, bottom);
		if (mTable != null)
		{
			String NOW_METHOD_NAME = Thread.currentThread() .getStackTrace()[2].getMethodName();
			try
			{
				LuaObject mTableValue = mTable.getField(NOW_METHOD_NAME);
				if (!mTableValue.isNil())
				{
					if (mTableValue.isFunction())
					{
						LuaFunction mFunction = mTableValue.getFunction();
						//需要传入的参数
						mFunction.call(changed, left, top, right, bottom, this);
					}
					else
					{
						throw new LuaException("\n" + NOW_METHOD_NAME + "不是一个function");
					}
				}
			}
			catch (Exception e)
			{
				mContext.sendError(this.getClass() + "的" + NOW_METHOD_NAME + "方法异常", e);
			}
		}

	}

	
	@Override
	public boolean onTouchEvent(MotionEvent event)
	{
		if (mTable != null)
		{
			String NOW_METHOD_NAME = Thread.currentThread() .getStackTrace()[2].getMethodName();
			try
			{
				LuaObject mTableValue = mTable.getField(NOW_METHOD_NAME);
				if (!mTableValue.isNil())
				{
					if (mTableValue.isFunction())
					{
						LuaFunction mFunction = mTableValue.getFunction();
						//需要传入的参数
						mFunction.call(event, this);
					}
					else
					{
						throw new LuaException("\n" + NOW_METHOD_NAME + "不是一个function");
					}
				}
			}
			catch (Exception e)
			{
				mContext.sendError(this.getClass() + "的" + NOW_METHOD_NAME + "方法异常", e);
			}
		}
		return true;

	}









}

