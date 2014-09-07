t = require 'counterpart'
extend = require 'extend'

core = require 'rui/core'
util = require 'rui/util'
Icon = require 'rui/Icon'
Input = require 'rui/Input'
Anchor = require 'rui/Anchor'
Button = require 'rui/Button'
Select = require 'rui/Select'
ActivityIndicator = require 'rui/ActivityIndicator'

{table, thead, tbody, tr, th, td, img} = require 'rui/DOM'

Permission = require 'rdb/Permission'

BackboneMixins = require 'rdb/BackboneMixins'
ComponentMixins = require 'rdb/ComponentMixins'

Row = core.createComponent 'rdb.Permission.Row',
  mixins: [BackboneMixins.ModelView]

  render: ->
    tr [
      td className: 'rdb-name', [
        @renderPermissionSymbol()
        @props.model.getName()
      ]
      td className: 'rdb-roles', [
        Anchor
          className: if @props.model.isRead() then 'rdb-active'
          onPrimary: => @refs['indicator'].track @props.model.setRead()
          t 'rdb.permissions.read'
        Anchor
          className: if @props.model.isEdit() then 'rdb-active'
          onPrimary: => @refs['indicator'].track @props.model.setEdit()
          t 'rdb.permissions.edit'
        Anchor
          className: if @props.model.isAdmin() then 'rdb-active'
          onPrimary: => @refs['indicator'].track @props.model.setAdmin()
          t 'rdb.permissions.admin'
      ]
      td className: 'rdb-actions', [
        Anchor
          icon: 'trash-o',
          onPrimary: => @props.onDelete @props.model.destroy()
          t('rdb.contextual.remove')
      ]
      td [
        ActivityIndicator ref: 'indicator'
      ]
    ]

  renderPermissionSymbol: ->
    if @props.model.getAvatarUrl()?
      img src: @props.model.getAvatarUrl(), className: 'rdb-avatar'
    else
      switch @props.model.getType()
        when 'user'
          Icon glyph: 'user'
        else
          Icon glyph: 'users'


Editor = core.createComponent 'rdb.Permission.Editor',
  mixins: [BackboneMixins.CollectionView]

  getDefaultProps: ->
    collection: @props.board.getPermissions()

  componentDidMount: ->
    # @props.collection.fetch()

  render: ->
    table className: 'rdb-permissions', [
      thead [ @renderPermissionHead() ]
      tbody @renderCollectionItems (item) =>
        Row
          model: item
          onDelete: (promise) => @refs['indicator'].track promise
    ]

  addPermission: ->
    id   = @refs['id'].value()
    role = @refs['role'].value()

    @props.collection.create
      role: role,
      principal:
        type: 'user',
        id: id
    @props.collection.fetch merge: true

  renderPermissionHead: ->
    tr [
      th [
        Input ref: 'id'
      ]
      th [
        Select ref: 'role', [
          Select.Option value: 'read', t 'rdb.permissions.read'
          Select.Option value: 'edit', t 'rdb.permissions.edit'
          Select.Option value: 'admin', t 'rdb.permissions.admin'
        ]
      ]
      th [
        Button
          onClick: (e) => @addPermission()
          'Add'
      ]
      th [
        ActivityIndicator ref: 'indicator'
      ]
    ]

module.exports =
  Editor: Editor
